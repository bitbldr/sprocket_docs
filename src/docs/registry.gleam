import sprocket.{render}
import sprocket/renderers/html.{html_renderer}
import sprocket/component.{component}
import docs/components/examples/counter_example.{
  counter_example, props_for_counter_example,
}

pub fn render_component_html(
  name: String,
  props: List(#(String, String)),
) -> Result(String, Nil) {
  case name {
    "counter_example" -> {
      props_for_counter_example(props)
      |> component(counter_example, _)
      |> render(html_renderer())
      |> Ok
    }
    _ -> Error(Nil)
  }
}

pub fn get_component_with_props(name: String, props: List(#(String, String))) {
  case name {
    "counter_example" -> {
      Ok(#(counter_example, props_for_counter_example(props)))
    }
    _ -> Error(Nil)
  }
}
