import sprocket/html/elements.{div, text}
import sprocket/html/attributes.{class}

pub fn unexpected_error() {
  div([class("border-2 border-red-500 bg-red-200 rounded p-3")], [
    text("An unexpected error occurred."),
  ])
}
