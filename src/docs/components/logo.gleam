import sprocket/html/attributes.{class}
import sprocket/html/elements.{div, fragment, keyed, span, text}

pub type LogoOpts {
  LogoOpts(show_icon: Bool)
}

pub fn logo(opts: LogoOpts) {
  fragment([
    keyed("icon", case opts.show_icon {
      True ->
        span(
          [
            class(
              "text-2xl inline-block animate-spin repeat-1 delay-500 ease-in-out mr-2",
            ),
          ],
          [text("⚙️")],
        )
      False -> fragment([])
    }),
    span([class("font-sprocket-logo italic text-xl text-[#205a96]")], [
      text("SPROCKET"),
    ]),
  ])
}

pub fn tagline() {
  div([class("text-gray-500 text-sm hidden sm:block")], [
    text("A library for building server components in Gleam ✨"),
  ])
}
