import gleam/int
import gleam/string
import gleam/list
import gleam/pair
import gleam/result
import gleam/function
import gleam/otp/actor.{Spec}
import gleam/erlang/process.{type Subject}
import simplifile
import djot
import docs/utils/common.{priv_directory}
import docs/page_route.{type PageRoute, PageRoute}
import docs/utils/ordered_map.{type OrderedMap}
import docs/registry.{render_component_html}

const call_timeout = 5000

pub type PageServer =
  Subject(Message)

pub type Page {
  Page(uri: String, title: String, content: String)
}

pub opaque type State {
  State(pages: OrderedMap(String, Page))
}

pub opaque type Message {
  Shutdown
  GetPage(caller: Subject(Result(Page, Nil)), name: String)
  ListPageRoutes(caller: Subject(List(PageRoute)))
}

fn handle_message(message: Message, state: State) -> actor.Next(Message, State) {
  case message {
    Shutdown -> {
      actor.Stop(process.Normal)
    }
    GetPage(caller, name) -> {
      actor.send(caller, ordered_map.get(state.pages, name))

      actor.continue(state)
    }
    ListPageRoutes(caller) -> {
      let titles =
        state.pages
        |> ordered_map.to_list()
        |> list.map(fn(page) { PageRoute(page.title, page.uri) })

      actor.send(caller, titles)

      actor.continue(state)
    }
  }
}

pub fn start() {
  let init = fn() {
    let self = process.new_subject()

    let state = State(pages: load_pages())

    let selector =
      process.selecting(process.new_selector(), self, function.identity)

    actor.Ready(state, selector)
  }

  actor.start_spec(Spec(init, call_timeout, handle_message))
}

fn load_pages() -> OrderedMap(String, Page) {
  let pages_directory = priv_directory() <> "/pages"

  let assert Ok(files) =
    pages_directory
    |> simplifile.read_directory()

  files
  // we are only interested in djot files so check the file extension and filter out the rest
  // and remove the extension from the file name
  |> list.filter_map(fn(file) {
    file
    |> string.split(".")
    |> fn(parts) {
      let parts_length = list.length(parts)
      case parts_length > 1, list.last(parts) {
        True, Ok("djot") -> {
          let filename =
            list.take(parts, parts_length - 1)
            |> string.join("")

          let #(index, basename, filename) =
            filename
            // check to see if the file has an ordinal idetifier with and underscore
            |> string.split_once("_")
            |> result.map(fn(p) {
              case int.parse(pair.first(p)) {
                // if the first part is a number, treat as ordinal identifier and just
                // use the second part as the basename
                Ok(index) -> #(index, pair.second(p), filename)
                Error(_) -> #(-1, filename, filename)
              }
            })
            // if the file doesn't have an underscore, use the whole file as the basename
            |> result.unwrap(#(-1, filename, filename))

          Ok(#(index, basename, "djot", filename))
        }
        _, _ -> Error(Nil)
      }
    }
  })
  |> list.sort(fn(f1, f2) {
    let #(index1, _, _, _) = f1
    let #(index2, _, _, _) = f2

    int.compare(index1, index2)
  })
  |> list.fold(ordered_map.new(), fn(pages, file) {
    let #(_index, basename, ext, filename) = file

    case simplifile.read(pages_directory <> "/" <> filename <> "." <> ext) {
      Ok(content) -> {
        let html = djot.to_html(content, render_component_html)

        let uri = urlify(basename)

        // TODO: parse title from content
        let title = basename

        ordered_map.insert(pages, uri, Page(uri, title, html))
      }
      Error(_) -> {
        pages
      }
    }
  })
}

fn urlify(path: String) -> String {
  path
  |> string.lowercase()
  |> string.replace(" ", "-")
}

pub fn get_page(actor: PageServer, name: String) -> Result(Page, Nil) {
  actor.call(actor, GetPage(_, name), call_timeout)
}

pub fn list_page_routes(actor: PageServer) -> List(PageRoute) {
  actor.call(actor, ListPageRoutes(_), call_timeout)
}
