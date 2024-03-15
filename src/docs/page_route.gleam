import gleam/string
import gleam/list
import gleam/result

pub type Page {
  Page(title: String, route: PageRoute)
}

pub type PageRoute {
  PageRoute(title: String, name: String)
}

pub fn name_from_path(path: String) -> String {
  let path = case string.ends_with(path, "/connect") {
    True -> string.slice(path, 0, string.length(path) - 8)
    False -> path
  }

  let path = case path {
    "" -> "/"
    _ -> path
  }

  case path {
    "/" -> "index"
    path -> {
      path
      |> string.split("#")
      |> list.first()
      |> result.try(fn(first) {
        first
        |> string.split("/")
        |> list.last()
      })
      |> result.unwrap("index")
    }
  }
}

pub fn href(route: PageRoute) -> String {
  "/" <> route.name
}
