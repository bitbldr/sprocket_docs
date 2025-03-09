import docs/components/codeblock.{codeblock}
import docs/components/counter.{counter}
import docs/components/examples/analog_clock_example.{analog_clock_example}
import docs/components/examples/button_example.{button_example}
import docs/components/examples/clock_example.{clock_example}
import docs/components/examples/counter_example.{counter_example}
import docs/components/examples/greeting_button_example.{greeting_button_example}
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
import gleam/dict.{type Dict}
import gleam/http/request.{type Request}
import gleam/option.{type Option}
import mist.{type Connection}
import sprocket_mist
import sprocket.{render}
import sprocket/component.{component}
import sprocket/renderers/html.{html_renderer}

pub fn render_component_html(
  name: String,
  attrs: Option(Dict(String, String)),
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

    "greeting_button_example" -> {
      attrs
      |> greeting_button_example.props_from()
      |> component(greeting_button_example, _)
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
  validate_csrf: fn(String) -> Result(Nil, Nil),
  name: String,
) {
  case name {
    "codeblock" -> {
      sprocket_mist.component(
        request,
        codeblock,
        codeblock.props_from,
        validate_csrf,
      )
      |> Ok
    }

    "counter" -> {
      sprocket_mist.component(
        request,
        counter,
        counter.props_from,
        validate_csrf,
      )
      |> Ok
    }

    "counter_example" -> {
      sprocket_mist.component(
        request,
        counter_example,
        counter_example.props_from,
        validate_csrf,
      )
      |> Ok
    }

    "button_example" -> {
      sprocket_mist.component(
        request,
        button_example,
        button_example.props_from,
        validate_csrf,
      )
      |> Ok
    }

    "toggle_button_with_render_label" -> {
      sprocket_mist.component(
        request,
        toggle_button_with_render_label,
        toggle_button_with_render_label.props_from,
        validate_csrf,
      )
      |> Ok
    }

    "product_card_example" -> {
      sprocket_mist.component(
        request,
        product_card_example,
        product_card_example.props_from,
        validate_csrf,
      )
      |> Ok
    }

    "stateful_product_card_example" -> {
      sprocket_mist.component(
        request,
        stateful_product_card_example,
        stateful_product_card_example.props_from,
        validate_csrf,
      )
      |> Ok
    }

    "product_list_example" -> {
      sprocket_mist.component(
        request,
        product_list_example,
        product_list_example.props_from,
        validate_csrf,
      )
      |> Ok
    }

    "props_and_events_counter_example" -> {
      sprocket_mist.component(
        request,
        props_and_events_counter_example,
        props_and_events_counter_example.props_from,
        validate_csrf,
      )
      |> Ok
    }

    "greeting_button_example" -> {
      sprocket_mist.component(
        request,
        greeting_button_example,
        greeting_button_example.props_from,
        validate_csrf,
      )
      |> Ok
    }

    "clock_example" -> {
      sprocket_mist.component(
        request,
        clock_example,
        clock_example.props_from,
        validate_csrf,
      )
      |> Ok
    }

    "analog_clock_example" -> {
      sprocket_mist.component(
        request,
        analog_clock_example,
        analog_clock_example.props_from,
        validate_csrf,
      )
      |> Ok
    }

    _ -> Error(Nil)
  }
}
