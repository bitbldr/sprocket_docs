import docs/components/common.{example}
import docs/components/example_button.{ExampleButtonProps, example_button}
import gleam/dict
import gleam/option.{type Option, None, Some}
import sprocket/component.{component, render}
import sprocket/context.{type Context}

pub fn props_from(attrs: Option(List(#(String, String)))) {
  case attrs {
    None -> ButtonExampleProps(label: None)
    Some(attrs) -> {
      let attrs =
        attrs
        |> dict.from_list()

      let label =
        attrs
        |> dict.get("label")
        |> option.from_result

      ButtonExampleProps(label: label)
    }
  }
}

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
