import gleam/io
import gleam/option.{None, Some}
import gleam/dynamic
import sprocket/context.{type Context, type Element}
import sprocket/component.{render}
import sprocket/hooks.{client, consumer, handler, state}
import sprocket/html/elements.{button, div, div_text, i, span, span_text, text}
import sprocket/html/attributes.{class, classes, on_click}
import docs/theme.{type DarkMode, Auto, Dark, Light, Theme}

pub type DarkModeToggleProps {
  DarkModeToggleProps
}

pub fn dark_mode_toggle(ctx: Context, _props: DarkModeToggleProps) {
  use ctx, is_open, set_open <- state(ctx, False)

  use ctx, Theme(mode: mode, set_mode: set_mode) <- consumer(ctx, "theme")

  use ctx, dark_mode_client, send_dark_mode_client <- client(
    ctx,
    "DarkMode",
    Some(fn(msg, payload, _send) {
      case msg {
        "click_outside" -> {
          case is_open {
            True -> set_open(False)
            False -> Nil
          }
          Nil
        }
        "set_mode" -> {
          io.debug(#(msg, payload))

          case option.map(payload, dynamic.string) {
            Some(Ok(theme)) -> {
              case theme {
                "light" -> set_mode(Light)
                "dark" -> set_mode(Dark)
                _ -> Nil
              }
            }
            _ -> Nil
          }
        }
        _ -> Nil
      }
    }),
  )

  use ctx, toggle_open <- handler(ctx, fn(_) { set_open(!is_open) })
  use ctx, set_mode_auto <- handler(
    ctx,
    fn(_) {
      let _ = send_dark_mode_client("set_mode", Some("auto"))
      set_mode(Auto)
      set_open(False)
    },
  )
  use ctx, set_mode_light <- handler(
    ctx,
    fn(_) {
      let _ = send_dark_mode_client("set_mode", Some("light"))
      set_mode(Light)
      set_open(False)
    },
  )
  use ctx, set_mode_dark <- handler(
    ctx,
    fn(_) {
      let _ = send_dark_mode_client("set_mode", Some("dark"))
      set_mode(Dark)
      set_open(False)
    },
  )

  render(
    ctx,
    div(
      [dark_mode_client(), class("m-4")],
      [
        case is_open {
          True ->
            div(
              [
                classes([
                  Some("flex-row"),
                  case is_open {
                    True -> Some("flex flex-row")
                    False -> Some("hidden")
                  },
                ]),
              ],
              [
                button(
                  [
                    on_click(set_mode_auto),
                    classes([
                      Some(
                        "p-2 rounded-l border border-gray-200 hover:bg-gray-100 active:bg-gray-200",
                      ),
                      Some(selector_class(Auto, mode)),
                    ]),
                  ],
                  [icon(Auto)],
                ),
                button(
                  [
                    on_click(set_mode_light),
                    classes([
                      Some(
                        "p-2 border-t border-b border-gray-200 hover:bg-gray-100 active:bg-gray-200",
                      ),
                      Some(selector_class(Light, mode)),
                    ]),
                  ],
                  [icon(Light)],
                ),
                button(
                  [
                    on_click(set_mode_dark),
                    classes([
                      Some(
                        "p-2 rounded-r border border-gray-200 hover:bg-gray-100 active:bg-gray-200",
                      ),
                      Some(selector_class(Dark, mode)),
                    ]),
                  ],
                  [icon(Dark)],
                ),
              ],
            )
          False ->
            button(
              [
                on_click(toggle_open),
                class("p-2 rounded border border-gray-200"),
              ],
              [icon(mode)],
            )
        },
      ],
    ),
  )
}

fn icon(mode: DarkMode) -> Element {
  case mode {
    Auto -> i([class("fa-solid fa-circle-half-stroke")], [])
    Light -> i([class("fa-solid fa-sun")], [])
    Dark -> i([class("fa-solid fa-moon")], [])
  }
}

fn selector_class(mode: DarkMode, current_mode: DarkMode) -> String {
  case mode == current_mode {
    True -> "text-gray-200 bg-gray-800 hover:bg-gray-800 active:bg-gray-800"
    False -> "hover:bg-gray-100 active:bg-gray-200"
  }
}
