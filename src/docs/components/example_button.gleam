import gleam/option.{type Option, None, Some}
import sprocket/context.{type Context}
import sprocket/component.{render}
import sprocket/html/elements.{button, text}
import sprocket/html/attributes.{class}

pub type ExampleButtonProps {
  ExampleButtonProps(label: Option(String))
}

pub fn example_button(ctx: Context, props: ExampleButtonProps) {
  let ExampleButtonProps(label) = props

  render(
    ctx,
    button(
      [
        class(
          "p-2 bg-blue-500 hover:bg-blue-600 active:bg-blue-700 text-white rounded-lg",
        ),
      ],
      [
        text(case label {
          Some(label) -> label
          None -> "Click me!"
        }),
      ],
    ),
  )
}
