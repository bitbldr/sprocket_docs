import gleam/option.{Some}
import sprocket.{type Element}
import sprocket/html/attributes.{class, classes}
import sprocket/html/elements.{div}

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
