import docs/components/dark_mode_toggle.{DarkModeToggleProps, dark_mode_toggle}
import docs/components/logo.{LogoOpts, logo}
import gleam/list
import gleam/string
import sprocket.{type Context, component, render}
import sprocket/html/attributes.{class, href}
import sprocket/html/elements.{a, div, i, span, text}

pub type MenuItem {
  MenuItem(label: String, href: String)
}

pub type HeaderProps {
  HeaderProps(menu_items: List(MenuItem))
}

pub fn header(ctx: Context, props) {
  let HeaderProps(menu_items: menu_items) = props

  render(
    ctx,
    div(
      [
        class(
          "flex flex-row border-b border-gray-200 dark:border-gray-600 min-h-[60px]",
        ),
      ],
      [
        a([href("/"), class("flex flex-row items-center")], [
          div([class("p-2 mx-3")], [
            logo(LogoOpts(show_icon: True)),
            logo.tagline(),
          ]),
        ]),
        div([class("flex-1")], []),
        div([class("flex flex-row items-center")], [
          div([class("hidden md:block")], [
            component(dark_mode_toggle, DarkModeToggleProps),
          ]),
          elements.fragment(
            list.map(menu_items, fn(item) {
              component(menu_item, MenuItemProps(item))
            }),
          ),
        ]),
      ],
    ),
  )
}

type MenuItemProps {
  MenuItemProps(item: MenuItem)
}

fn menu_item(ctx: Context, props: MenuItemProps) {
  let MenuItemProps(item: MenuItem(label: label, href: href)) = props

  let is_external = is_external_href(href)

  render(
    ctx,
    a(
      [
        class(
          "inline-flex items-baseline px-3 hover:text-blue-500 hover:underline",
        ),
        attributes.href(href),
        ..case is_external {
          True -> [attributes.target("_blank")]
          False -> []
        }
      ],
      [
        text(label),
        ..case is_external {
          True -> [
            span([class("text-gray-500 text-sm ml-2")], [
              i([class("fa-solid fa-arrow-up-right-from-square")], []),
            ]),
          ]
          False -> []
        }
      ],
    ),
  )
}

fn is_external_href(href: String) -> Bool {
  string.starts_with(href, "http://") || string.starts_with(href, "https://")
}
