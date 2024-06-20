import gleam/list
import gleam/result
import gleam/string

pub type Page {
  Page(title: String, route: PageRoute)
}

pub type PageRoute {
  PageRoute(title: String, uri: String)
}

pub fn name_from_path(path: String, default default: String) -> String {
  let path =
    path
    |> without_connect()
    |> trim_slashes()

  case path {
    "" -> default
    path -> {
      path
      |> string.split("#")
      |> list.first()
      |> result.try(fn(first) {
        first
        |> string.split("/")
        |> list.last()
      })
      |> result.unwrap(default)
    }
  }
}

pub fn href(route: PageRoute) -> String {
  "/" <> route.uri
}

fn without_connect(path: String) -> String {
  case string.ends_with(path, "/connect") {
    True -> string.slice(path, 0, string.length(path) - 8)
    False -> path
  }
}

fn trim_slashes(path: String) -> String {
  let path = case string.starts_with(path, "/") {
    True -> string.slice(path, 1, string.length(path))
    False -> path
  }

  let path = case string.ends_with(path, "/") {
    True -> string.slice(path, 0, string.length(path) - 1)
    False -> path
  }

  path
}
