import gleam/int
import gleam/result
import gleam/option.{None, Some}
import gleam/dict.{type Dict}
import sprocket.{render}
import sprocket/renderers/html.{html_renderer}
import sprocket/component.{component}
import sprocket/context.{type FunctionalComponent}
import docs/components/counter.{CounterProps, counter}

pub fn render_component_html(
  name: String,
  props: Dict(String, String),
) -> Result(String, Nil) {
  case name {
    "counter" -> {
      props_for_counter(props)
      |> component(counter, _)
      |> render(html_renderer())
      |> Ok
    }
    _ -> Error(Nil)
  }
}

pub fn get_component_with_props(name: String, props: Dict(String, String)) {
  case name {
    "counter" -> {
      Ok(#(counter, props_for_counter(props)))
    }
    _ -> Error(Nil)
  }
}

fn props_for_counter(props: Dict(String, String)) {
  let initial =
    dict.get(props, "initial")
    |> result.try(int.parse)
    |> fn(result) {
      case result {
        Ok(value) -> Some(value)
        Error(_) -> None
      }
    }

  CounterProps(initial)
}
