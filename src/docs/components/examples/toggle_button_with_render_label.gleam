import docs/components/common.{example}
import docs/components/toggle_button.{ToggleButtonProps, toggle_button}
import gleam/dict.{type Dict}
import gleam/option.{type Option, None, Some}
import sprocket/component.{component, render}
import sprocket/context.{type Context}
import sprocket/html/attributes.{class}
import sprocket/html/elements.{i, span, text}

pub fn props_from(attrs: Option(Dict(String, String))) {
  case attrs {
    None -> ToggleButtonWithRenderLabelProps
    Some(_attrs) -> ToggleButtonWithRenderLabelProps
  }
}

pub type ToggleButtonWithRenderLabelProps {
  ToggleButtonWithRenderLabelProps
}

pub fn toggle_button_with_render_label(
  ctx: Context,
  _props: ToggleButtonWithRenderLabelProps,
) {
  render(
    ctx,
    example([
      component(
        toggle_button,
        ToggleButtonProps(render_label: fn(toggle) {
          case toggle {
            True ->
              span([], [
                i([class("fa-solid fa-check mr-2")], []),
                text("Added to Cart!"),
              ])
            False ->
              span([], [
                i([class("fa-solid fa-cart-shopping mr-2")], []),
                text("Add to Cart"),
              ])
          }
        }),
      ),
    ]),
  )
}
