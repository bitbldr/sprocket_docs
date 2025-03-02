import docs/components/common.{example}
import docs/components/greeting_button.{GreetingButtonProps, greeting_button}
import gleam/dict.{type Dict}
import gleam/option.{type Option, None, Some}
import sprocket/component.{component, render}
import sprocket/context.{type Context}

pub fn props_from(attrs: Option(Dict(String, String))) {
  case attrs {
    None -> GreetingButtonExample
    Some(_attrs) -> GreetingButtonExample
  }
}

pub type GreetingButtonExample {
  GreetingButtonExample
}

pub fn greeting_button_example(ctx: Context, _props: GreetingButtonExample) {
  render(ctx, example([component(greeting_button, GreetingButtonProps)]))
}
