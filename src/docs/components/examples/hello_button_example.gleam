import docs/components/common.{example}
import docs/components/hello_button.{HelloButtonProps, hello_button}
import gleam/option.{type Option, None, Some}
import sprocket/component.{component, render}
import sprocket/context.{type Context}

pub fn props_from(attrs: Option(List(#(String, String)))) {
  case attrs {
    None -> HelloButtonExample
    Some(_attrs) -> HelloButtonExample
  }
}

pub type HelloButtonExample {
  HelloButtonExample
}

pub fn hello_button_example(ctx: Context, _props: HelloButtonExample) {
  render(ctx, example([component(hello_button, HelloButtonProps)]))
}
