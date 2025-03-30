import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/option.{type Option, None, Some}
import gleam/result
import sprocket.{type Context, render}
import sprocket/html/attributes.{class}
import sprocket/html/elements.{button, text}

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

pub fn props_from(attrs: Option(Dynamic)) -> ExampleButtonProps {
  let default = ExampleButtonProps(label: None)

  case attrs {
    None -> default
    Some(attrs) -> {
      decode.run(attrs, {
        use label <- decode.optional_field(
          "label",
          None,
          decode.optional(decode.string),
        )

        decode.success(ExampleButtonProps(label: label))
      })
      |> result.unwrap(default)
    }
  }
}
