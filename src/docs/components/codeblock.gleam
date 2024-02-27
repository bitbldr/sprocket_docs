import gleam/string
import gleam/list
import gleam/int
import gleam/option.{None}
import sprocket/context.{type Context}
import sprocket/component.{render}
import sprocket/html/elements.{code_text, div, ignored, pre}
import sprocket/html/attributes.{class}
import sprocket/hooks.{client}

pub type CodeBlockProps {
  CodeBlockProps(language: String, body: String)
}

pub fn codeblock(ctx: Context, props: CodeBlockProps) {
  let CodeBlockProps(language, body) = props

  use ctx, code_block_client, _send_codeblock_client <- client(
    ctx,
    "CodeBlock",
    None,
  )

  render(
    ctx,
    div([class("not-prose overflow-x-auto text-sm")], [
      ignored(
        pre([], [
          code_text(
            [
              code_block_client(),
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
      case acc, count_leading_spaces(line, 0) {
        0, count -> count
        _, 0 -> acc
        _, count -> int.min(acc, count)
      }
    })

  code
  |> string.split("\n")
  |> list.map(fn(line) {
    case string.pop_grapheme(line) {
      // check if the line has leading whitespace. if so, trim it to the minimum
      // amount found on any single line. otherwise, return the line as-is.
      Ok(#(" ", _)) -> {
        string.slice(
          line,
          min_leading_spaces,
          string.length(line) - min_leading_spaces,
        )
      }
      _ -> line
    }
  })
  |> string.join("\n")
}

fn count_leading_spaces(line: String, count: Int) {
  case string.pop_grapheme(line) {
    Ok(#(" ", rest)) -> count_leading_spaces(rest, count + 1)
    _ -> count
  }
}
