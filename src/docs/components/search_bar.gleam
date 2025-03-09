import gleam/option.{None, Some}
import sprocket/component.{type Context, render}
import sprocket/hooks.{reducer}
import sprocket/html/attributes.{class, input_type, placeholder, value}
import sprocket/html/elements.{input}
import sprocket/html/events

type Model {
  Model(query: String)
}

type Msg {
  NoOp
  SetQuery(query: String)
}

fn update(model: Model, msg: Msg) {
  case msg {
    NoOp -> #(model, [])
    SetQuery(query) -> #(Model(query: query), [])
  }
}

fn init() {
  #(Model(query: ""), [])
}

pub type SearchBarProps {
  SearchBarProps(on_search: fn(String) -> Nil)
}

pub fn search_bar(ctx: Context, props) {
  let SearchBarProps(on_search: on_search) = props

  // Define a reducer to handle events and update the state
  use ctx, Model(query: query), dispatch <- reducer(ctx, init(), update)

  let on_input_query = fn(e) {
    case events.decode_target_value(e) {
      Ok(value) -> {
        on_search(value)
        dispatch(SetQuery(value))
      }
      Error(_) -> Nil
    }
  }

  render(
    ctx,
    input([
      input_type("text"),
      class(
        "m-2 pl-2 pr-4 py-1 rounded bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-600 focus:outline-none focus:border-blue-500",
      ),
      placeholder("Search..."),
      value(query),
      events.on_input(on_input_query),
    ]),
  )
}
