import docs/page_route.{type PageRoute}
import docs/utils/common.{maybe}
import docs/utils/ordered_map.{type OrderedMap}
import gleam/option.{Some}
import gleam/result
import sprocket/component.{type Context, component, render}
import sprocket/html/attributes.{class, classes}
import sprocket/html/elements.{a, div, fragment, hr, i, text}

pub type PrevNextNavProps {
  PrevNextNavProps(pages: OrderedMap(String, PageRoute), active: String)
}

pub fn prev_next_nav(ctx: Context, props) {
  let PrevNextNavProps(pages: pages, active: active) = props

  let prev_page = ordered_map.find_previous(pages, active)
  let next_page = ordered_map.find_next(pages, active)

  render(
    ctx,
    fragment([
      hr([class("text-gray-500 my-6")]),
      div([class("flex flex-row my-6")], [
        component(link, PageLinkProps(prev_page, active, Prev)),
        div([class("flex-1")], []),
        component(link, PageLinkProps(next_page, active, Next)),
      ]),
    ]),
  )
}

type NextOrPrev {
  Next
  Prev
}

type PageLinkProps {
  PageLinkProps(
    page: Result(PageRoute, Nil),
    active: String,
    next_or_prev: NextOrPrev,
  )
}

fn link(ctx: Context, props: PageLinkProps) {
  let PageLinkProps(page: page, active: active, next_or_prev: next_or_prev) =
    props

  render(
    ctx,
    page
      |> result.map(fn(page) {
        let title = page.title
        let href = page_route.href(page)
        let is_active = page.uri == active

        a(
          [
            classes([
              Some(
                "block py-1.5 px-2 text-blue-500 hover:text-blue-600 active:text-blue-700 no-underline hover:!underline",
              ),
              maybe(is_active, "font-bold"),
            ]),
            attributes.href(href),
          ],
          case next_or_prev {
            Next -> [text(title), next_or_prev_icon(Next)]
            Prev -> [next_or_prev_icon(Prev), text(title)]
          },
        )
      })
      |> result.unwrap(fragment([])),
  )
}

fn next_or_prev_icon(next_or_prev: NextOrPrev) {
  case next_or_prev {
    Next -> i([class("fa-solid fa-arrow-right ml-3")], [])
    Prev -> i([class("fa-solid fa-arrow-left mr-3")], [])
  }
}
