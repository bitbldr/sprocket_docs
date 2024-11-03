import docs/utils/logger
import gleam/int
import sprocket/component.{render}
import sprocket/context.{type Context}
import sprocket/hooks.{handler, reducer}
import sprocket/html/attributes.{class}
import sprocket/html/elements.{div, span, text}
import sprocket/html/events

type Model =
  #(Int, Int)

type Msg {
  UpdatePosition(Int, Int)
  ResetPosition
}

fn init() {
  #(#(0, 0), [])
}

fn update(_model: Model, msg: Msg) {
  case msg {
    UpdatePosition(x, y) -> {
      #(#(x, y), [])
    }
    ResetPosition -> #(#(0, 0), [])
  }
}

pub type MousepadProps {
  MousepadProps
}

pub fn mousepad(ctx: Context, _props: MousepadProps) {
  // Define a reducer to handle events and update the state
  use ctx, count, dispatch <- reducer(ctx, init(), update)

  use ctx, handle_mousemove <- handler(ctx, fn(e) {
    case events.decode_mouse_event(e) {
      Ok(events.MouseEvent(x:, y:, ..)) -> dispatch(UpdatePosition(x, y))
      Error(_) -> {
        logger.error("Error decoding mouse position")

        dispatch(ResetPosition)
      }
    }
  })

  render(
    ctx,
    div(
      [
        class("flex flex-row m-4 w-[500px] h-[250px] bg-gray-200 rounded"),
        events.on_mousemove(handle_mousemove),
      ],
      [
        div([class("flex flex-col items-center justify-end")], [
          span([class("text-2xl")], [text("Mouse position")]),
          span([class("text-4xl")], [
            text("X: "),
            text(int.to_string(count.0)),
            text(" Y: "),
            text(int.to_string(count.1)),
          ]),
        ]),
      ],
    ),
  )
}
