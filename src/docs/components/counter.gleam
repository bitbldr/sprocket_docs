import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import sprocket/component.{type Context, render}
import sprocket/hooks.{dep, effect, reducer}
import sprocket/html/attributes.{class}
import sprocket/html/elements.{button, div, span, text}
import sprocket/html/events

type Model =
  Int

type Msg {
  UpdateCounter(Int)
}

fn init(initial: Int) {
  #(initial, [])
}

fn update(_model: Model, msg: Msg) {
  case msg {
    UpdateCounter(count) -> {
      #(count, [])
    }
  }
}

pub type CounterProps {
  CounterProps(initial: Option(Int))
}

pub fn counter(ctx: Context, props: CounterProps) {
  let CounterProps(initial) = props

  // Define a reducer to handle events and update the state
  use ctx, count, dispatch <- reducer(
    ctx,
    init(option.unwrap(initial, 0)),
    update,
  )

  // Example effect that runs every time count changes
  use ctx <- effect(
    ctx,
    fn() {
      io.println(string.append("Count: ", int.to_string(count)))
      None
    },
    [dep(count)],
  )

  // Define event handlers
  let increment = fn(_) { dispatch(UpdateCounter(count + 1)) }
  let decrement = fn(_) { dispatch(UpdateCounter(count - 1)) }

  render(
    ctx,
    div([class("flex flex-row m-4")], [
      button(
        [
          class(
            "p-1 px-2 border dark:border-gray-500 rounded-l bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 active:bg-gray-300 dark:active:bg-gray-600",
          ),
          events.on_click(decrement),
        ],
        [text("-")],
      ),
      span(
        [
          class(
            "p-1 px-2 w-10 border-t border-b dark:border-gray-500 align-center text-center",
          ),
        ],
        [text(int.to_string(count))],
      ),
      button(
        [
          class(
            "p-1 px-2 border dark:border-gray-500 rounded-r bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 active:bg-gray-300 dark:active:bg-gray-600",
          ),
          events.on_click(increment),
        ],
        [text("+")],
      ),
    ]),
  )
}

pub fn props_from(attrs: Option(Dict(String, String))) {
  case attrs {
    None -> CounterProps(initial: None)
    Some(attrs) -> {
      let initial =
        attrs
        |> dict.get("initial")
        |> result.try(int.parse)
        |> option.from_result

      CounterProps(initial: initial)
    }
  }
}
