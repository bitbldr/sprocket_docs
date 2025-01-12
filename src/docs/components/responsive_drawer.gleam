import gleam/option.{Some}
import sprocket/component.{render}
import sprocket/context.{type Context, type Element}
import sprocket/hooks.{reducer}
import sprocket/html/attributes.{class, classes}
import sprocket/html/elements.{aside, button, div, i}
import sprocket/html/events

type Model {
  Model(show: Bool)
}

type Msg {
  NoOp
  Show
  Hide
  Toggle
}

fn update(model: Model, msg: Msg) {
  case msg {
    NoOp -> #(model, [])
    Show -> #(Model(show: True), [])
    Hide -> #(Model(show: False), [])
    Toggle -> #(Model(show: !model.show), [])
  }
}

fn init() {
  #(Model(show: False), [])
}

pub type ResponsiveDrawerProps {
  ResponsiveDrawerProps(drawer: Element, content: Element)
}

pub fn responsive_drawer(ctx: Context, props) {
  let ResponsiveDrawerProps(drawer: drawer, content: content) = props

  use ctx, Model(show: show), dispatch <- reducer(ctx, init(), update)

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
      div([class("w-0")], [
        button(
          [
            events.on_click(toggle_drawer),
            class(
              "
                    sticky
                    top-2
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
      ]),
      div([class("flex-1 overflow-hidden")], [content]),
      ..case show {
        True -> [backdrop]
        False -> []
      }
    ]),
  )
}
