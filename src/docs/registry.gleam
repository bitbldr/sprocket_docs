import docs/components/codeblock.{codeblock}
import docs/components/counter.{counter}
import docs/components/examples/analog_clock_example.{analog_clock_example}
import docs/components/examples/button_example.{button_example}
import docs/components/examples/clock_example.{clock_example}
import docs/components/examples/counter_example.{counter_example}
import docs/components/examples/hello_button_example.{hello_button_example}
import docs/components/examples/product_card_example.{product_card_example}
import docs/components/examples/product_list_example.{product_list_example}
import docs/components/examples/props_and_events_counter_example.{
  props_and_events_counter_example,
}
import docs/components/examples/stateful_product_card_example.{
  stateful_product_card_example,
}
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

    "counter" -> {
      attrs
      |> counter.props_from()
      |> component(counter, _)
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

    "product_card_example" -> {
      attrs
      |> product_card_example.props_from()
      |> component(product_card_example, _)
      |> render(html_renderer())
      |> Ok
    }

    "stateful_product_card_example" -> {
      attrs
      |> stateful_product_card_example.props_from()
      |> component(stateful_product_card_example, _)
      |> render(html_renderer())
      |> Ok
    }

    "product_list_example" -> {
      attrs
      |> product_list_example.props_from()
      |> component(product_list_example, _)
      |> render(html_renderer())
      |> Ok
    }

    "props_and_events_counter_example" -> {
      attrs
      |> props_and_events_counter_example.props_from()
      |> component(props_and_events_counter_example, _)
      |> render(html_renderer())
      |> Ok
    }

    "hello_button_example" -> {
      attrs
      |> hello_button_example.props_from()
      |> component(hello_button_example, _)
      |> render(html_renderer())
      |> Ok
    }

    "clock_example" -> {
      attrs
      |> clock_example.props_from()
      |> component(clock_example, _)
      |> render(html_renderer())
      |> Ok
    }

    "analog_clock_example" -> {
      attrs
      |> analog_clock_example.props_from()
      |> component(analog_clock_example, _)
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

    "counter" -> {
      mist_sprocket.component(
        request,
        counter,
        counter.props_from,
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

    "product_card_example" -> {
      mist_sprocket.component(
        request,
        product_card_example,
        product_card_example.props_from,
        validate_csrf,
        None,
      )
      |> Ok
    }

    "stateful_product_card_example" -> {
      mist_sprocket.component(
        request,
        stateful_product_card_example,
        stateful_product_card_example.props_from,
        validate_csrf,
        None,
      )
      |> Ok
    }

    "product_list_example" -> {
      mist_sprocket.component(
        request,
        product_list_example,
        product_list_example.props_from,
        validate_csrf,
        None,
      )
      |> Ok
    }

    "props_and_events_counter_example" -> {
      mist_sprocket.component(
        request,
        props_and_events_counter_example,
        props_and_events_counter_example.props_from,
        validate_csrf,
        None,
      )
      |> Ok
    }

    "hello_button_example" -> {
      mist_sprocket.component(
        request,
        hello_button_example,
        hello_button_example.props_from,
        validate_csrf,
        None,
      )
      |> Ok
    }

    "clock_example" -> {
      mist_sprocket.component(
        request,
        clock_example,
        clock_example.props_from,
        validate_csrf,
        None,
      )
      |> Ok
    }

    "analog_clock_example" -> {
      mist_sprocket.component(
        request,
        analog_clock_example,
        analog_clock_example.props_from,
        validate_csrf,
        None,
      )
      |> Ok
    }

    _ -> Error(Nil)
  }
}
