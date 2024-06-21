import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import sprocket.{type PropList}
import sprocket/component.{render}
import sprocket/context.{type Context}
import sprocket/hooks.{client}
import sprocket/html/attributes.{class}
import sprocket/html/elements.{code_text, div, ignore, pre}

pub fn props_from(attrs: Option(PropList)) {
  case attrs {
    None -> CodeBlockProps("", "")
    Some(attrs) -> {
      let attrs =
        attrs
        |> dict.from_list()

      let language =
        attrs
        |> dict.get("language")
        |> result.unwrap("")

      let body =
        attrs
        |> dict.get("inner_html")
        |> result.unwrap("")

      CodeBlockProps(language, body)
    }
  }
}

pub type CodeBlockProps {
  CodeBlockProps(language: String, body: String)
}

pub fn codeblock(ctx: Context, props: CodeBlockProps) {
  let CodeBlockProps(language, body) = props

  use ctx, client_code_block, _dispatch_client_send_codeblock <- client(
    ctx,
    "CodeBlock",
    None,
  )

  render(
    ctx,
    div([class("not-prose overflow-x-auto text-sm")], [
      ignore(
        pre([], [
          code_text(
            [
              client_code_block(),
              class("language-" <> language <> " rounded-lg"),
            ],
            process_code(body),
          ),
        ]),
      ),
    ]),
  )
}

pub fn process_code(code: String) {
  // trim leading and trailing whitespace
  let code =
    code
    |> string.trim()

  // normalize leading whitespace to the minimum amount found on any single line
  let min_leading_spaces =
    code
    |> string.split("\n")
    |> list.fold(0, fn(acc, line) {
      int.min(acc, count_leading_spaces(line, 0))
    })

  code
  |> string.split("\n")
  |> list.map(fn(line) {
    string.slice(
      line,
      min_leading_spaces,
      string.length(line) - min_leading_spaces,
    )
  })
  |> string.join("\n")
}

fn count_leading_spaces(line: String, count: Int) {
  case string.pop_grapheme(line) {
    Ok(#(" ", rest)) -> count_leading_spaces(rest, count + 1)
    _ -> count
  }
}
