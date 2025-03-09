import docs/components/common.{example}
import docs/components/greeting_button.{GreetingButtonProps, greeting_button}
import gleam/dynamic.{type Dynamic}
import gleam/option.{type Option, None, Some}
import sprocket/component.{type Context, component, render}

pub type GreetingButtonExampleProps {
  GreetingButtonExampleProps
}

pub fn greeting_button_example(ctx: Context, _props: GreetingButtonExampleProps) {
  render(ctx, example([component(greeting_button, GreetingButtonProps)]))
}

pub fn props_from(attrs: Option(Dynamic)) -> GreetingButtonExampleProps {
  case attrs {
    None -> GreetingButtonExampleProps
    Some(_attrs) -> GreetingButtonExampleProps
  }
}
