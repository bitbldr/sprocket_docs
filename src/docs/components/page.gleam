import docs/app_context.{type AppContext}
import docs/components/header.{HeaderProps, MenuItem, header}
import docs/components/pages/not_found.{NotFoundPageProps, not_found_page}
import docs/components/prev_next_nav.{PrevNextNavProps, prev_next_nav}
import docs/components/responsive_drawer.{
  ResponsiveDrawerProps, responsive_drawer,
}
import docs/components/sidebar.{SidebarProps, sidebar}
import docs/page_route
import docs/page_server
import docs/theme.{type DarkMode, type Theme, Auto, Theme}
import docs/utils/ordered_map.{KeyedItem}
import gleam/list
import gleam/option.{None}
import sprocket.{type Context, component, render}
import sprocket/hooks.{type Dispatcher, client, memo, reducer} as _
import sprocket/html/attributes.{class, id}
import sprocket/html/elements.{div, ignore, raw}

type Model {
  Model(mode: DarkMode)
}

type Msg {
  SetMode(mode: DarkMode)
}

fn update(_model: Model, msg: Msg, _dispatch: Dispatcher(Msg)) -> Model {
  case msg {
    SetMode(mode) -> Model(mode: mode)
  }
}

fn init() {
  fn(_dispatch) { Model(Auto) }
}

pub type PageProps {
  PageProps(app: AppContext, path: String)
}

pub fn page(ctx: Context, props: PageProps) {
  let PageProps(app, path: path) = props

  let current_page_name =
    page_route.name_from_path(path, default: "introduction")

  let page_content = page_server.get_page(app.page_server, current_page_name)

  use ctx, Model(mode), dispatch <- reducer(ctx, init(), update)

  use ctx, pages <- memo(
    ctx,
    fn() {
      page_server.list_page_routes(app.page_server)
      |> list.map(fn(page_route) { KeyedItem(page_route.uri, page_route) })
      |> ordered_map.from_list()
    },
    [],
  )

  use ctx, load_components_client, _ <- client(ctx, "LoadComponents", None)

  use ctx, client_hljs, _dispatch_hljs <- client(ctx, "HighlightJS", None)

  render(
    ctx,
    div([id("app")], [
      theme.provider(
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
      component(
        responsive_drawer,
        ResponsiveDrawerProps(
          drawer: component(sidebar, SidebarProps(pages, current_page_name)),
          content: div(
            [
              class(
                "prose dark:prose-invert prose-sm md:prose-base container mx-auto py-6 px-4 sm:px-8 md:px-10",
              ),
              client_hljs(),
            ],
            [
              case page_content {
                Ok(page_server.Page(_, _, html)) ->
                  div([load_components_client()], [ignore(raw("div", [], html))])
                _ -> component(not_found_page, NotFoundPageProps)
              },
              component(
                prev_next_nav,
                PrevNextNavProps(pages, current_page_name),
              ),
            ],
          ),
        ),
      ),
    ]),
  )
}
