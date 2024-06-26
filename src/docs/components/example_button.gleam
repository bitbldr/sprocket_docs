import gleam/dict
import gleam/option.{type Option, None, Some}
import sprocket/component.{render}
import sprocket/context.{type Context}
import sprocket/html/attributes.{class}
import sprocket/html/elements.{button, text}

pub fn props_from(attrs: Option(List(#(String, String)))) {
  case attrs {
    None -> ExampleButtonProps(label: None)
    Some(attrs) -> {
      let attrs =
        attrs
        |> dict.from_list()

      let label =
        attrs
        |> dict.get("label")
        |> option.from_result

      ExampleButtonProps(label: label)
    }
  }
}

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
