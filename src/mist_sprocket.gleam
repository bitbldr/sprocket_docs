import docs/utils/csrf.{type CSRFValidator}
import gleam/bytes_tree
import gleam/dict.{type Dict}
import gleam/erlang/process.{type Selector}
import gleam/function
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/otp/actor
import gleam/result
import mist.{
  type Connection, type ResponseData, type WebsocketConnection,
  type WebsocketMessage,
}
import sprocket.{
  type RuntimeEvent, type Sprocket, type StatefulComponent,
  ClientHookEventMessage, EventMessage, JoinMessage, render
}
import sprocket/context.{type Element}
import sprocket/internal/logger
import sprocket/renderers/html.{html_renderer}

type State {
  Initialized(ws_send: fn(String) -> Result(Nil, Nil))
  Running(Sprocket)
}

pub fn component(
  req: Request(Connection),
  component: StatefulComponent(p),
  initialize_props: fn(Option(Dict(String, String))) -> p,
  validate_csrf: CSRFValidator,
) -> Response(ResponseData) {
  // if the request path ends with "connect", then start a websocket connection
  case list.last(request.path_segments(req)) {
    Ok("connect") -> {
      mist.websocket(
        request: req,
        on_init: initializer(),
        on_close: terminator(),
        handler: component_handler(component, initialize_props, validate_csrf),
      )
    }

    _ -> {
      let el = sprocket.component(component, initialize_props(None))

      let body = render(el, html_renderer())

      response.new(200)
      |> response.prepend_header("content-type", "text/html")
      |> response.set_body(
        body
        |> bytes_tree.from_string
        |> mist.Bytes,
      )
    }
  }
}

pub fn view(
  req: Request(Connection),
  layout: fn(Element) -> Element,
  el: Element,
  validate_csrf: CSRFValidator,
) -> Response(ResponseData) {
  // if the request path ends with "connect", then start a websocket connection
  case list.last(request.path_segments(req)) {
    Ok("connect") -> {
      mist.websocket(
        request: req,
        on_init: initializer(),
        on_close: terminator(),
        handler: view_handler(el, validate_csrf),
      )
    }
    _ -> {
      let body = render(layout(el), html_renderer())

      response.new(200)
      |> response.prepend_header("content-type", "text/html")
      |> response.set_body(
        body
        |> bytes_tree.from_string
        |> mist.Bytes,
      )
    }
  }
}

fn initializer() {
  fn(_conn: WebsocketConnection) -> #(State, Option(Selector(String))) {
    let self = process.new_subject()

    let selector =
      process.new_selector()
      |> process.selecting(self, function.identity)

    // Create a function that will send messages to this websocket
    let ws_send = fn(msg) {
      process.send(self, msg)
      |> Ok
    }

    #(Initialized(ws_send), Some(selector))
  }
}

fn terminator() {
  fn(state: State) {
    use spkt <- require_running(state, or_else: fn() { Nil })

    let _ = sprocket.shutdown(spkt)

    Nil
  }
}

fn component_handler(
  component: StatefulComponent(p),
  initialize_props: fn(Option(Dict(String, String))) -> p,
  validate_csrf: CSRFValidator,
) {
  fn(state: State, conn: WebsocketConnection, message: WebsocketMessage(String)) {
    use msg <- mist_text_message(conn, state, message)

    case sprocket.decode_message(msg) {
      Ok(JoinMessage(id, csrf_token, initial_props)) -> {
        case validate_csrf(csrf_token) {
          Ok(_) -> {
            use ws_send <- require_initialized(state, or_else: fn() {
              logger.error("Sprocket must be initialized first before joining")

              actor.continue(state)
            })

            let el =
              sprocket.component(
                component,
                initialize_props(initial_props),
              )

            let dispatch = fn(event: RuntimeEvent) {
              event
              |> sprocket.event_to_json()
              |> json.to_string()
              |> ws_send()
            }

            let spkt =
              sprocket.start(el, dispatch)
              |> result.map_error(sprocket.humanize_error)

            case spkt {
              Ok(spkt) -> actor.continue(Running(spkt))
              Error(err) -> {
                logger.error("Failed to start sprocket: " <> err)

                actor.continue(state)
              }
            }
          }

          Error(_) -> {
            logger.error("Invalid CSRF token")

            actor.continue(state)
          }
        }
      }
      Ok(EventMessage(element_id, kind, payload)) -> {
        use spkt <- require_running(state, or_else: fn() {
          logger.error(
            "Sprocket must be connected first before receiving events",
          )

          actor.continue(state)
        })

        logger.debug("Event: element " <> element_id <> " " <> kind)

        sprocket.process_event(spkt, element_id, kind, payload)

        actor.continue(state)
      }
      Ok(ClientHookEventMessage(element_id, hook, kind, payload)) -> {
        use spkt <- require_running(state, or_else: fn() {
          logger.error(
            "Sprocket must be connected first before receiving hook events",
          )

          actor.continue(state)
        })

        logger.debug(
          "Hook Event: element " <> element_id <> " " <> hook <> " " <> kind,
        )

        sprocket.process_client_hook_event(
          spkt,
          element_id,
          hook,
          kind,
          payload,
        )

        actor.continue(state)
      }
      _ -> {
        logger.error("Error decoding message: " <> msg)

        actor.continue(state)
      }
    }
  }
}

fn view_handler(el: Element, validate_csrf: CSRFValidator) {
  fn(state: State, conn: WebsocketConnection, message: WebsocketMessage(String)) {
    use msg <- mist_text_message(conn, state, message)

    case sprocket.decode_message(msg) {
      Ok(JoinMessage(_id, csrf_token, _initial_props)) -> {
        case validate_csrf(csrf_token) {
          Ok(_) -> {
            use ws_send <- require_initialized(state, or_else: fn() {
              logger.error("Sprocket must be initialized first before joining")

              actor.continue(state)
            })

            let dispatch = fn(event: RuntimeEvent) {
              event
              |> sprocket.event_to_json()
              |> json.to_string()
              |> ws_send()
            }

            let spkt =
              sprocket.start(el, dispatch)
              |> result.map_error(sprocket.humanize_error)

            case spkt {
              Ok(spkt) -> actor.continue(Running(spkt))
              Error(err) -> {
                logger.error("Failed to start sprocket: " <> err)

                actor.continue(state)
              }
            }
          }

          Error(_) -> {
            logger.error("Invalid CSRF token")

            actor.continue(state)
          }
        }
      }
      Ok(EventMessage(element_id, kind, payload)) -> {
        use spkt <- require_running(state, or_else: fn() {
          logger.error(
            "Sprocket must be connected first before receiving events",
          )

          actor.continue(state)
        })

        logger.debug("Event: element " <> element_id <> " " <> kind)

        sprocket.process_event(spkt, element_id, kind, payload)

        actor.continue(state)
      }
      Ok(ClientHookEventMessage(element_id, hook, kind, payload)) -> {
        use spkt <- require_running(state, or_else: fn() {
          logger.error(
            "Sprocket must be connected first before receiving hook events",
          )

          actor.continue(state)
        })

        logger.debug(
          "Hook Event: element " <> element_id <> " " <> hook <> " " <> kind,
        )

        sprocket.process_client_hook_event(
          spkt,
          element_id,
          hook,
          kind,
          payload,
        )

        actor.continue(state)
      }
      _ -> {
        logger.error("Error decoding message: " <> msg)

        actor.continue(state)
      }
    }
  }
}

fn mist_text_message(
  conn: WebsocketConnection,
  state: State,
  message: WebsocketMessage(String),
  cb,
) {
  case message {
    mist.Text(msg) -> cb(msg)
    mist.Binary(_) -> actor.continue(state)
    mist.Custom(msg) -> {
      let _ =
        mist.send_text_frame(conn, msg)
        |> result.map_error(fn(reason) {
          logger.error("Failed to send websocket message: " <> msg)
          io.debug(reason)

          Nil
        })

      actor.continue(state)
    }
    mist.Closed | mist.Shutdown -> actor.Stop(process.Normal)
  }
}

fn require_initialized(
  state: State,
  or_else bail: fn() -> a,
  cb cb: fn(fn(String) -> Result(Nil, Nil)) -> a,
) {
  case state {
    Initialized(dispatch) -> cb(dispatch)
    _ -> bail()
  }
}

fn require_running(
  state: State,
  or_else bail: fn() -> a,
  cb cb: fn(Sprocket) -> a,
) {
  case state {
    Running(spkt) -> cb(spkt)
    _ -> bail()
  }
}
