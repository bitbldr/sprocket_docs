import gleam/list
import sprocket/context.{type Context, provider}
import sprocket/component.{component, render}
import sprocket/html/elements.{div}
import sprocket/html/attributes.{class, id}
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
import docs/components/pages/misc.{MiscPageProps, misc_page}
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
  type PageRoute, Components, Effects, Events, GettingStarted, Hooks,
  Introduction, Misc, Page, StateManagement, UnderTheHood, Unknown,
}
import docs/theme.{type DarkMode, type Theme, Auto, Theme}

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

pub type PageProps {
  PageProps(route: PageRoute)
}

pub fn page(ctx: Context, props: PageProps) {
  let PageProps(route: route) = props

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
        Page("Misc.", Misc),
      ]
      |> list.map(fn(page) { KeyedItem(page.route, page) })
      |> ordered_map.from_list()
    },
    context.OnMount,
  )

  render(
    ctx,
    div([id("app")], [
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
                Components -> component(components_page, ComponentsPageProps)
                Events ->
                  component(props_and_events_page, PropsAndEventsPageProps)
                StateManagement ->
                  component(state_management_page, StateManagementPageProps)
                Hooks -> component(hooks_page, HooksPageProps)
                Effects -> component(effects_page, EffectsPageProps)
                UnderTheHood ->
                  component(under_the_hood_page, UnderTheHoodProps)
                Misc -> component(misc_page, MiscPageProps)
                Unknown -> component(not_found_page, NotFoundPageProps)
              },
              component(prev_next_nav, PrevNextNavProps(pages, route)),
            ],
          ),
        ),
      ),
    ]),
  )
}
