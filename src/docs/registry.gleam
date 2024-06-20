import docs/components/codeblock.{codeblock}
import docs/components/examples/button_example.{button_example}
import docs/components/examples/counter_example.{counter_example}
import docs/components/examples/toggle_button_with_render_label.{
  toggle_button_with_render_label,
}
import gleam/http/request.{type Request}
import gleam/option.{type Option, None}
import mist.{type Connection}
import mist_sprocket
import sprocket.{type CSRFValidator, render}
import sprocket/component.{component}
import sprocket/renderers/html.{html_renderer}

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
    "button_example" -> {
      attrs
      |> button_example.props_from()
      |> component(button_example, _)
      |> render(html_renderer())
      |> Ok
    }
    "toggle_button_with_render_label" -> {
      attrs
      |> toggle_button_with_render_label.props_from()
      |> component(toggle_button_with_render_label, _)
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

    "button_example" -> {
      mist_sprocket.component(
        request,
        button_example,
        button_example.props_from,
        validate_csrf,
        None,
      )
      |> Ok
    }

    "toggle_button_with_render_label" -> {
      mist_sprocket.component(
        request,
        toggle_button_with_render_label,
        toggle_button_with_render_label.props_from,
        validate_csrf,
        None,
      )
      |> Ok
    }

    _ -> Error(Nil)
  }
}
