import gleam/option.{None, Some}
import sprocket/context.{type Element}
import sprocket/html/attributes.{
  charset, class, content, crossorigin, href, id, integrity, lang, media, name,
  referrerpolicy, rel, src,
}
import sprocket/html/elements.{body, head, html, link, meta, script, title}

pub fn page_layout(page_title: String, csrf: String) {
  fn(inner_content: Element) {
    html([lang("en")], [
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
        script(
          [],
          Some(
            "
            if (localStorage.getItem('theme') === 'dark') {
              document.getElementsByTagName( 'html' )[0].classList.add('dark');
            }
            ",
          ),
        ),
      ]),
      body(
        [
          class(
            "bg-white dark:bg-gray-900 dark:text-white flex flex-col h-screen",
          ),
        ],
        [inner_content, script([src("/app.js")], None)],
      ),
    ])
  }
}
