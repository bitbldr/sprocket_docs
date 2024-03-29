import gleam/list
import gleam/result
import gleam/option.{None, Some}
import sprocket/context.{type Context, provider}
import sprocket/component.{component, render}
import sprocket/html/elements.{body, div, head, html, link, meta, script, title}
import sprocket/html/attributes.{
  charset, class, content, crossorigin, href, id, integrity, lang, media, name,
  referrerpolicy, rel, src,
}
import sprocket/hooks.{memo, reducer} as _
import sprocket/internal/utils/ordered_map.{KeyedItem}
import docs/components/header.{HeaderProps, MenuItem, header}
import docs/components/responsive_drawer.{
  ResponsiveDrawerProps, responsive_drawer,
}
import docs/components/sidebar.{SidebarProps, sidebar}
import docs/components/prev_next_nav.{PrevNextNavProps, prev_next_nav}
import docs/components/pages/introduction.{
  IntroductionPageProps, introduction_page,
}
import docs/components/pages/getting_started.{
  GettingStartedPageProps, getting_started_page,
}
import docs/components/pages/components.{ComponentsPageProps, components_page}
import docs/components/pages/examples.{ExamplesPageProps, examples_page}
import docs/components/pages/not_found.{NotFoundPageProps, not_found_page}
import docs/components/pages/hooks.{HooksPageProps, hooks_page}
import docs/components/pages/props_and_events.{
  PropsAndEventsPageProps, props_and_events_page,
}
import docs/components/pages/effects.{EffectsPageProps, effects_page}
import docs/components/pages/state_management.{
  StateManagementPageProps, state_management_page,
}
import docs/components/pages/under_the_hood.{
  UnderTheHoodProps, under_the_hood_page,
}
import docs/page_route.{
  type PageRoute, Components, Effects, Events, Examples, GettingStarted, Hooks,
  Introduction, Page, StateManagement, UnderTheHood, Unknown,
}
import docs/theme.{type DarkMode, type Theme, Auto, Dark, Theme}

type Model {
  Model(mode: DarkMode)
}

type Msg {
  SetMode(mode: DarkMode)
}

fn update(_model: Model, msg: Msg) -> Model {
  case msg {
    SetMode(mode) -> Model(mode: mode)
  }
}

fn initial() -> Model {
  Model(Auto)
}

pub type PageViewProps {
  PageViewProps(route: PageRoute, csrf: String)
}

pub fn page_view(ctx: Context, props: PageViewProps) {
  let PageViewProps(route: route, csrf: csrf) = props

  use ctx, Model(mode), dispatch <- reducer(ctx, initial(), update)

  use ctx, pages <- memo(
    ctx,
    fn() {
      [
        Page("Introduction", Introduction),
        Page("Getting Started", GettingStarted),
        Page("Components", Components),
        Page("Props and Events", Events),
        Page("State Management", StateManagement),
        Page("Hooks", Hooks),
        Page("Effects", Effects),
        Page("Under the Hood", UnderTheHood),
        Page("Examples", Examples),
      ]
      |> list.map(fn(page) { KeyedItem(page.route, page) })
      |> ordered_map.from_list()
    },
    context.OnMount,
  )

  use ctx, page_title <- memo(
    ctx,
    fn() {
      pages
      |> ordered_map.get(route)
      |> result.map(fn(page) { page.title <> " - Sprocket" })
      |> result.unwrap("Sprocket")
    },
    context.OnMount,
  )

  render(
    ctx,
    html([lang("en"), class(theme_class(mode))], [
      head([], [
        title(page_title),
        meta([charset("utf-8")]),
        meta([name("csrf-token"), content(csrf)]),
        meta([name("viewport"), content("width=device-width, initial-scale=1")]),
        meta([
          name("description"),
          content(
            "Sprocket is a library for building real-time server components in Gleam.",
          ),
        ]),
        meta([
          name("keywords"),
          content(
            "gleam, sprocket, web, server, real-time, components, html, css, javascript",
          ),
        ]),
        // Set the <meta name="theme-color"> tag for mobile browsers to render correct colors
        meta([name("theme-color"), content(meta_theme_color(mode))]),
        link([rel("stylesheet"), href("/app.css")]),
        link([
          rel("stylesheet"),
          href(
            "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.1/css/all.min.css",
          ),
          integrity(
            "sha512-MV7K8+y+gLIBoVD59lQIYicR65iaqukzvf/nwasF0nqhPay5w/9lJmVM2hMDcnK1OnMGCdVK+iQrJ7lzPJQd1w==",
          ),
          crossorigin("anonymous"),
          referrerpolicy("no-referrer"),
        ]),
        link([
          id("syntax-theme"),
          rel("stylesheet"),
          media("(prefers-color-scheme: dark)"),
          href(
            "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/atom-one-dark.min.css",
          ),
        ]),
        link([
          id("syntax-theme"),
          rel("stylesheet"),
          media(
            "(prefers-color-scheme: light), (prefers-color-scheme: no-preference)",
          ),
          href(
            "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/atom-one-light.min.css",
          ),
        ]),
        script(
          [
            src(
              "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js",
            ),
          ],
          None,
        ),
        script([src("https://gleam.run/javascript/highlightjs-gleam.js")], None),
      ]),
      body(
        [
          class(
            "bg-white dark:bg-gray-900 dark:text-white flex flex-col h-screen",
          ),
        ],
        [
          div([], [
            provider(
              "theme",
              Theme(mode: mode, set_mode: fn(mode) { dispatch(SetMode(mode)) }),
              div([], [
                component(
                  header,
                  HeaderProps(menu_items: [
                    MenuItem("Github", "https://github.com/bitbldr/sprocket"),
                  ]),
                ),
              ]),
            ),
          ]),
          component(
            responsive_drawer,
            ResponsiveDrawerProps(
              drawer: component(sidebar, SidebarProps(pages, route)),
              content: div(
                [
                  class(
                    "prose dark:prose-invert prose-sm md:prose-base container mx-auto p-12",
                  ),
                ],
                [
                  case route {
                    Introduction ->
                      component(introduction_page, IntroductionPageProps)
                    GettingStarted ->
                      component(getting_started_page, GettingStartedPageProps)
                    Components ->
                      component(components_page, ComponentsPageProps)
                    Events ->
                      component(props_and_events_page, PropsAndEventsPageProps)
                    StateManagement ->
                      component(state_management_page, StateManagementPageProps)
                    Hooks -> component(hooks_page, HooksPageProps)
                    Effects -> component(effects_page, EffectsPageProps)
                    UnderTheHood ->
                      component(under_the_hood_page, UnderTheHoodProps)
                    Examples -> component(examples_page, ExamplesPageProps)
                    Unknown -> component(not_found_page, NotFoundPageProps)
                  },
                  component(prev_next_nav, PrevNextNavProps(pages, route)),
                ],
              ),
            ),
          ),
          script([src("/app.js")], None),
          script([], Some("hljs.highlightAll();")),
        ],
      ),
    ]),
  )
}

fn theme_class(mode: DarkMode) -> String {
  case mode {
    Dark -> "dark"
    _ -> "light"
  }
}

fn meta_theme_color(mode: DarkMode) -> String {
  case mode {
    Dark -> "#111827"
    _ -> "#ffffff"
  }
}
