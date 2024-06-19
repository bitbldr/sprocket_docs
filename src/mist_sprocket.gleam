import gleam/bytes_builder.{type BytesBuilder}
import gleam/erlang/process
import gleam/function
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/otp/actor
import gleam/result
import mist.{
  type Connection, type ResponseData, type WebsocketConnection,
  type WebsocketMessage,
}
import sprocket.{
  type CSRFValidator, type PropList, type Sprocket, type SprocketOpts, Empty,
  Joined, render,
}
import sprocket/component as sprocket_component
import sprocket/context.{type Element, type FunctionalComponent}
import sprocket/internal/logger
import sprocket/renderers/html.{html_renderer}

type State(p) {
  State(spkt: Sprocket(p))
}

pub fn component(
  req: Request(Connection),
  view: FunctionalComponent(p),
  initial_props: fn(Option(PropList)) -> p,
  csrf_validator: CSRFValidator,
  opts: Option(SprocketOpts),
) -> Response(ResponseData) {
  let self = process.new_subject()
  let selector =
    process.new_selector()
    |> process.selecting(self, function.identity)

  // if the request path ends with "connect", then start a websocket connection
  case list.last(request.path_segments(req)) {
    Ok("connect") -> {
      mist.websocket(
        request: req,
        on_init: fn(_conn) {
          #(
            State(sprocket.new(
              view,
              initial_props,
              fn(msg) { process.send(self, msg) |> Ok },
              csrf_validator,
              opts,
            )),
            Some(selector),
          )
        },
        on_close: fn(state) {
          let _ = sprocket.cleanup(state.spkt)
          Nil
        },
        handler: handle_ws_message,
      )
    }

    _ -> {
      let el = sprocket_component.component(view, initial_props(None))

      let body = render(el, html_renderer())

      response.new(200)
      |> response.set_body(body)
      |> response.prepend_header("content-type", "text/html")
      |> response.map(bytes_builder.from_string)
      |> mist_response()
    }
  }
}

pub fn view(
  req: Request(Connection),
  layout: fn(Element) -> Element,
  view: FunctionalComponent(p),
  initial_props: fn(Option(PropList)) -> p,
  csrf_validator: CSRFValidator,
  opts: Option(SprocketOpts),
) -> Response(ResponseData) {
  let self = process.new_subject()
  let selector =
    process.new_selector()
    |> process.selecting(self, function.identity)

  // if the request path ends with "connect", then start a websocket connection
  case list.last(request.path_segments(req)) {
    Ok("connect") -> {
      mist.websocket(
        request: req,
        on_init: fn(_conn) {
          #(
            State(sprocket.new(
              view,
              initial_props,
              // sender(self),
              fn(msg) {
                io.debug("sending message to websocket")
                process.send(self, msg) |> Ok
              },
              csrf_validator,
              opts,
            )),
            Some(selector),
          )
        },
        on_close: fn(state) {
          let _ = sprocket.cleanup(state.spkt)
          Nil
        },
        handler: handle_ws_message,
      )
    }
    _ -> {
      let el = sprocket_component.component(view, initial_props(None))

      let body = render(layout(el), html_renderer())

      response.new(200)
      |> response.set_body(body)
      |> response.prepend_header("content-type", "text/html")
      |> response.map(bytes_builder.from_string)
      |> mist_response()
    }
  }
}

fn mist_response(response: Response(BytesBuilder)) -> Response(ResponseData) {
  response.new(response.status)
  |> response.set_body(mist.Bytes(response.body))
}

fn handle_ws_message(
  state: State(a),
  conn: WebsocketConnection,
  message: WebsocketMessage(String),
) {
  let State(spkt) = state

  case message {
    mist.Text(msg) -> {
      case sprocket.handle_ws(spkt, msg) {
        Ok(response) -> {
          case response {
            Joined(spkt) -> {
              actor.continue(State(spkt))
            }
            Empty -> {
              actor.continue(state)
            }
          }
        }
        Error(err) -> {
          logger.error("failed to handle websocket message: " <> msg)
          io.debug(err)

          actor.continue(state)
        }
      }
    }

    mist.Custom(msg) -> {
      let assert Ok(_) =
        mist.send_text_frame(conn, msg)
        |> result.map_error(fn(reason) {
          logger.error("failed to send websocket message: " <> msg)
          io.debug(reason)

          Nil
        })

      actor.continue(state)
    }
    mist.Closed | mist.Shutdown -> {
      actor.Stop(process.Normal)
    }
    _ -> {
      logger.info("Received unsupported websocket message type")
      io.debug(message)

      actor.continue(state)
    }
  }
}
