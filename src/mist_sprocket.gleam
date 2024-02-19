import gleam/io
import gleam/option.{Some}
import gleam/list
import gleam/bit_array
import gleam/string
import gleam/result
import gleam/erlang
import gleam/bytes_builder.{type BytesBuilder}
import gleam/otp/actor
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import ids/uuid
import mist.{type Connection, type ResponseData}
import sprocket.{render}
import sprocket/cassette.{type Cassette}
import sprocket/component as sprocket_component
import sprocket/html/render as html_render
import sprocket/context.{type Element, type FunctionalComponent}
import sprocket/internal/logger

type State(p) {
  State(
    id: String,
    ca: Cassette,
    view: Element,
    ws_send: fn(String) -> Result(Nil, Nil),
  )
}

pub fn component(
  req: Request(Connection),
  ca: Cassette,
  view: FunctionalComponent(p),
  props: p,
) -> Response(ResponseData) {
  let selector = process.new_selector()
  let rendered_el = sprocket_component.component(view, props)

  // if the request path ends with "live", then start a websocket connection
  case list.last(request.path_segments(req)) {
    Ok("live") -> {
      let assert Ok(id) = uuid.generate_v4()

      mist.websocket(
        request: req,
        on_init: fn(conn) {
          #(State(id, ca, rendered_el, sender(conn)), Some(selector))
        },
        on_close: fn(_state) {
          let _ = sprocket.cleanup(ca, id)
          Nil
        },
        handler: handle_ws_message,
      )
    }

    _ -> {
      let body = render(rendered_el, html_render.renderer())

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
  ca: Cassette,
  layout: fn(Element) -> Element,
  view: FunctionalComponent(p),
  props: p,
) -> Response(ResponseData) {
  let selector = process.new_selector()
  let rendered_el = sprocket_component.component(view, props)

  // if the request path ends with "live", then start a websocket connection
  case list.last(request.path_segments(req)) {
    Ok("live") -> {
      let assert Ok(id) = uuid.generate_v4()

      mist.websocket(
        request: req,
        on_init: fn(conn) {
          #(State(id, ca, rendered_el, sender(conn)), Some(selector))
        },
        on_close: fn(_state) {
          let _ = sprocket.cleanup(ca, id)
          Nil
        },
        handler: handle_ws_message,
      )
    }
    _ -> {
      let body = render(layout(rendered_el), html_render.renderer())

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

fn handle_ws_message(state, _conn, message) {
  let State(id, ca, view, ws_send) = state

  case
    erlang.rescue(fn() {
      case message {
        mist.Text(msg) -> {
          let _ =
            sprocket.handle_client(id, ca, view, msg, ws_send)
            |> result.map_error(fn(reason) {
              logger.error("failed to handle websocket message: " <> msg)
              io.debug(reason)
            })

          actor.continue(state)
        }
        mist.Closed | mist.Shutdown -> actor.Stop(process.Normal)
        _ -> {
          logger.info("Received unsupported websocket message type")
          io.debug(message)

          actor.continue(state)
        }
      }
    })
  {
    Ok(response) -> response
    Error(error) -> {
      logger.error(string.inspect(error))

      panic
    }
  }
}

fn sender(conn) {
  fn(msg) {
    mist.send_text_frame(conn, msg)
    |> result.map_error(fn(reason) {
      logger.error("failed to send websocket message: " <> msg)
      io.debug(reason)

      Nil
    })
  }
}
