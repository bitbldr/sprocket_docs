import docs/components/dark_mode_toggle.{DarkModeToggleProps, dark_mode_toggle}
import docs/components/logo.{LogoOpts, logo}
import docs/utils/common
import gleam/io
import gleam/option.{None, Some}
import sprocket/component.{type Context, type Element, component, render}
import sprocket/hooks.{client, reducer}
import sprocket/html/attributes.{class, classes}
import sprocket/html/elements.{aside, button, div, fragment, i, keyed, text}
import sprocket/html/events

type Model {
  Model(show: Bool, show_logo: Bool)
}

type Msg {
  NoOp
  Show
  Hide
  Toggle
  ShowLogo(Bool)
}

fn update(model: Model, msg: Msg) {
  case msg {
    NoOp -> #(model, [])
    Show -> #(Model(..model, show: True), [])
    Hide -> #(Model(..model, show: False), [])
    Toggle -> #(Model(..model, show: !model.show), [])
    ShowLogo(show) -> #(Model(..model, show_logo: show), [])
  }
}

fn init() {
  #(Model(show: False, show_logo: False), [])
}

pub type ResponsiveDrawerProps {
  ResponsiveDrawerProps(drawer: Element, content: Element)
}

pub fn responsive_drawer(ctx: Context, props) {
  let ResponsiveDrawerProps(drawer: drawer, content: content) = props

  use ctx, Model(show: show, show_logo: show_logo), dispatch <- reducer(
    ctx,
    init(),
    update,
  )

  use ctx, scroll_observer_client, _ <- client(
    ctx,
    "ScrollObserver",
    Some(fn(event, _payload, _send) {
      case event {
        "out_of_view" -> {
          dispatch(ShowLogo(True))
        }
        "in_view" -> {
          dispatch(ShowLogo(False))
        }
        _ -> Nil
      }
    }),
  )

  let toggle_drawer = fn(_) { dispatch(Toggle) }
  let hide_drawer = fn(_) { dispatch(Hide) }

  let backdrop =
    div(
      [
        class("fixed bg-white/75 dark:bg-black/75 inset-0 z-30"),
        events.on_click(hide_drawer),
      ],
      [],
    )

  render(
    ctx,
    fragment([
      div([class("absolute top-[200px]"), scroll_observer_client()], []),
      div([class("md:hidden sticky top-0")], [
        div([class("flex flex-row bg-white dark:bg-gray-900")], [
          keyed(
            "menu_toggle",
            button(
              [
                events.on_click(toggle_drawer),
                class(
                  "
                    inline-flex
                    md:hidden
                    items-center
                    p-2
                    m-2
                    text-sm
                    text-gray-500
                    rounded-lg
                    hover:bg-gray-100
                    focus:outline-none
                    focus:ring-2
                    focus:ring-gray-200
                    dark:text-gray-400
                    dark:hover:bg-gray-700
                    dark:focus:ring-gray-600
                  ",
                ),
              ],
              [i([class("fa-solid fa-bars")], [])],
            ),
          ),
          keyed(
            "logo",
            div(
              [
                classes([
                  Some("p-2 flex-1 transition-all duration-200"),
                  case show_logo {
                    True -> Some("opacity-100 ")
                    False -> Some("opacity-0 ml-[-6px]")
                  },
                ]),
              ],
              [logo(LogoOpts(show_icon: False))],
            ),
          ),
          keyed(
            "dark_mode_toggle",
            div([class("block md:hidden m-2")], [
              component(dark_mode_toggle, DarkModeToggleProps),
            ]),
          ),
        ]),
      ]),
      div([classes([Some("flex-1 flex flex-row")])], [
        aside(
          [
            classes([
              case show {
                True -> Some("block fixed top-0 left-0 bottom-0")
                False -> Some("hidden")
              },
              Some(
                "md:block w-64 z-40 transition-transform -translate-x-full translate-x-0 transition-transform",
              ),
            ]),
          ],
          [
            div(
              [
                class(
                  "h-screen sticky top-0 px-3 py-4 overflow-y-auto bg-gray-100/75 dark:bg-gray-800/75 backdrop-blur-md",
                ),
              ],
              [drawer],
            ),
          ],
        ),
        div([class("flex-1 overflow-hidden")], [content]),
        ..case show {
          True -> [backdrop]
          False -> []
        }
      ]),
    ]),
  )
}
