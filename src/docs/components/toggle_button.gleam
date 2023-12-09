import sprocket/context.{type Context, type Element}
import sprocket/component.{render}
import sprocket/html/elements.{button}
import sprocket/html/attributes.{class, on_click}
import sprocket/hooks.{handler, state}

pub type ToggleButtonProps {
  ToggleButtonProps(render_label: fn(Bool) -> Element)
}

pub fn toggle_button(ctx: Context, props: ToggleButtonProps) {
  let ToggleButtonProps(render_label) = props

  // add a state hook to track the active state, we'll cover hooks in more detail later
  use ctx, is_active, set_active <- state(ctx, False)

  // add a handler hook to toggle the active state
  use ctx, toggle_active <- handler(
    ctx,
    fn(_) {
      set_active(!is_active)
      Nil
    },
  )

  render(
    ctx,
    [
      button(
        [
          class(case is_active {
            True ->
              "rounded-lg text-white px-3 py-2 bg-green-700 hover:bg-green-800 active:bg-green-900"
            False ->
              "rounded-lg text-white px-3 py-2 bg-blue-500 hover:bg-blue-600 active:bg-blue-700"
          }),
          on_click(toggle_active),
        ],
        [render_label(is_active)],
      ),
    ],
  )
}
