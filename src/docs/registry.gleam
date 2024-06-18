import gleam/option.{type Option, None}
import gleam/http/request.{type Request}
import mist.{type Connection}
import sprocket.{type CSRFValidator, render}
import sprocket/renderers/html.{html_renderer}
import sprocket/component.{component}
import mist_sprocket
import docs/components/examples/counter_example.{counter_example}
import docs/components/codeblock.{codeblock}

pub fn render_component_html(
  name: String,
  attrs: Option(List(#(String, String))),
) -> Result(String, Nil) {
  case name {
    "codeblock" -> {
      attrs
      |> codeblock.props_from()
      |> component(codeblock, _)
      |> render(html_renderer())
      |> Ok
    }
    "counter_example" -> {
      attrs
      |> counter_example.props_from()
      |> component(counter_example, _)
      |> render(html_renderer())
      |> Ok
    }
    _ -> Error(Nil)
  }
}

pub fn component_router(
  request: Request(Connection),
  validate_csrf: CSRFValidator,
  name: String,
) {
  case name {
    "codeblock" -> {
      mist_sprocket.component(
        request,
        codeblock,
        codeblock.props_from,
        validate_csrf,
        None,
      )
      |> Ok
    }

    "counter_example" -> {
      mist_sprocket.component(
        request,
        counter_example,
        counter_example.props_from,
        validate_csrf,
        None,
      )
      |> Ok
    }

    _ -> Error(Nil)
  }
}
