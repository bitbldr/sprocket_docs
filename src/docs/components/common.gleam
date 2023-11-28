import gleam/string
import gleam/list
import gleam/int
import gleam/option.{Some}
import sprocket/context.{type Element}
import sprocket/html/elements.{code_text, div, ignored, pre, span, text}
import sprocket/html/attributes.{class, classes}

pub fn example(children: List(Element)) -> Element {
  div(
    [
      class(
        "not-prose graph-paper bg-white dark:bg-black my-4 p-6 border border-gray-200 dark:border-gray-700 rounded-md overflow-x-auto",
      ),
    ],
    children,
  )
}

pub fn codeblock(language: String, body: String) {
  div(
    [class("not-prose overflow-x-auto text-sm")],
    [
      ignored(pre(
        [],
        [
          code_text(
            [class("language-" <> language <> " rounded-lg")],
            process_code(body),
          ),
        ],
      )),
    ],
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
    |> list.fold(
      0,
      fn(acc, line) {
        case acc, count_leading_spaces(line, 0) {
          0, count -> count
          _, 0 -> acc
          _, count -> int.min(acc, count)
        }
      },
    )

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

pub type AlertKind {
  Info
  Warning
  Error
}

fn alert_classes(kind: AlertKind) {
  case kind {
    Info -> "text-blue-800 bg-blue-50 dark:bg-gray-800 dark:text-blue-300"
    Warning ->
      "text-yellow-800 bg-yellow-50 dark:bg-gray-800 dark:text-yellow-300"
    Error -> "text-red-800 bg-red-50 dark:bg-gray-800 dark:text-red-300"
  }
}

pub fn alert(kind: AlertKind, body: List(Element)) -> Element {
  div(
    [
      classes([
        Some("flex flex-row py-4 px-6 mb-4 text-sm rounded-lg"),
        Some(alert_classes(kind)),
      ]),
    ],
    body,
  )
}
