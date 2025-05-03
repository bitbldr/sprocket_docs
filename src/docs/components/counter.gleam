import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/result
import sprocket.{type Context, component, render}
import sprocket/hooks.{type Dispatcher, reducer}
import sprocket/html/attributes.{class, classes}
import sprocket/html/elements.{button_text, div, span, text}
import sprocket/html/events

type Model =
  Int

type Msg {
  Increment
  Decrement
  SetCount(Int)
  Reset
}

fn init(initial: Int) {
  fn(_dispatch) { initial }
}

fn update(count: Model, msg: Msg, dispatch: Dispatcher(Msg)) -> Model {
  case msg {
    Increment -> {
      count + 1
    }

    Decrement -> {
      count - 1
    }

    SetCount(count) -> count

    Reset -> {
      dispatch(SetCount(0))

      count
    }
  }
}

pub type CounterProps {
  CounterProps(initial: Int, enable_reset: Bool)
}

pub fn counter(ctx: Context, props: CounterProps) {
  let CounterProps(initial: initial, enable_reset: enable_reset) = props

  // Define a reducer to handle events and update the state
  use ctx, count, dispatch <- reducer(ctx, init(initial), update)

  render(
    ctx,
    div([class("flex flex-row m-4")], [
      component(
        button,
        StyledButtonProps(class: "rounded-l", label: "-", on_click: fn() {
          dispatch(Decrement)
        }),
      ),
      component(
        display,
        DisplayProps(count: count, reset: fn() {
          case enable_reset {
            True -> dispatch(Reset)
            False -> Nil
          }
        }),
      ),
      component(
        button,
        StyledButtonProps(class: "rounded-r", label: "+", on_click: fn() {
          dispatch(Increment)
        }),
      ),
    ]),
  )
}

pub type ButtonProps {
  ButtonProps(label: String, on_click: fn() -> Nil)
  StyledButtonProps(class: String, label: String, on_click: fn() -> Nil)
}

pub fn button(ctx: Context, props: ButtonProps) {
  let #(class, label, on_click) = case props {
    ButtonProps(label, on_click) -> #(None, label, on_click)
    StyledButtonProps(class, label, on_click) -> #(Some(class), label, on_click)
  }

  render(
    ctx,
    button_text(
      [
        events.on_click(fn(_) { on_click() }),
        classes([
          class,
          Some(
            "p-1 px-2 border dark:border-gray-500 bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 active:bg-gray-300 dark:active:bg-gray-600",
          ),
        ]),
      ],
      label,
    ),
  )
}

pub type DisplayProps {
  DisplayProps(count: Int, reset: fn() -> Nil)
}

pub fn display(ctx: Context, props: DisplayProps) {
  let DisplayProps(count: count, reset: reset) = props

  render(
    ctx,
    span(
      [
        events.on_dblclick(fn(_) { reset() }),
        class(
          "p-1 px-2 w-10 bg-white dark:bg-gray-900 border-t border-b dark:border-gray-500 align-center text-center select-none",
        ),
      ],
      [text(int.to_string(count))],
    ),
  )
}

pub fn props_from(attrs: Option(Dynamic)) -> CounterProps {
  let default = CounterProps(initial: 0, enable_reset: False)

  case attrs {
    None -> default
    Some(attrs) -> {
      decode.run(attrs, {
        use initial <- decode.optional_field(
          "initial",
          default.initial,
          decode.string
            |> decode.map(int.parse)
            |> decode.map(result.unwrap(_, default.initial)),
        )

        use enable_reset <- decode.optional_field(
          "enable_reset",
          False,
          decode.bool,
        )

        decode.success(CounterProps(initial, enable_reset))
      })
      |> result.unwrap(default)
    }
  }
}
