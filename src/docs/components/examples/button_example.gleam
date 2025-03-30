import docs/components/common.{example}
import docs/components/example_button.{ExampleButtonProps, example_button}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/option.{type Option, None, Some}
import gleam/result
import sprocket.{type Context, component, render}

pub type ButtonExampleProps {
  ButtonExampleProps(label: Option(String))
}

pub fn button_example(ctx: Context, props: ButtonExampleProps) {
  let ButtonExampleProps(label) = props

  render(
    ctx,
    example([component(example_button, ExampleButtonProps(label: label))]),
  )
}

pub fn props_from(attrs: Option(Dynamic)) -> ButtonExampleProps {
  let default = ButtonExampleProps(label: None)
  case attrs {
    None -> default
    Some(attrs) -> {
      decode.run(attrs, {
        use label <- decode.optional_field(
          "label",
          None,
          decode.optional(decode.string),
        )

        decode.success(ButtonExampleProps(label: label))
      })
      |> result.unwrap(default)
    }
  }
}
