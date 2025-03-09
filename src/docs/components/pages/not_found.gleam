import sprocket/component.{type Context, render}
import sprocket/html/attributes.{class}
import sprocket/html/elements.{div, h1, text}

pub type NotFoundPageProps {
  NotFoundPageProps
}

pub fn not_found_page(ctx: Context, _props: NotFoundPageProps) {
  render(
    ctx,
    div([class("flex flex-col p-10")], [
      div([], [h1([class("text-xl mb-2")], [text("Page Not Found")])]),
    ]),
  )
}
