import gleam/string
import gleam/list
import gleam/pair
import gleam/result
import gleam/dict.{type Dict}
import gleam/function
import gleam/otp/actor.{Spec}
import gleam/erlang/process.{type Subject}
import simplifile
import jot
import docs/utils/common.{priv_directory}
import docs/page_route.{type PageRoute, PageRoute}

const call_timeout = 5000

pub type PageServer =
  Subject(Message)

pub type Page {
  Page(name: String, title: String, content: String)
}

pub opaque type State {
  State(pages: Dict(String, Page))
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
      actor.send(caller, dict.get(state.pages, name))

      actor.continue(state)
    }
    ListPageRoutes(caller) -> {
      let titles =
        state.pages
        |> dict.to_list()
        |> list.map(fn(page) {
          PageRoute(pair.second(page).title, pair.first(page))
        })

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

fn load_pages() -> Dict(String, Page) {
  let pages_directory = priv_directory() <> "/pages"

  let assert Ok(files) =
    pages_directory
    |> simplifile.read_directory()

  list.fold(files, dict.new(), fn(pages, file) {
    let assert Ok(basename) =
      file
      |> string.split(on: "/")
      |> list.last
      |> result.try(fn(name) {
        name
        |> string.split(".")
        |> list.first()
      })

    case simplifile.read(pages_directory <> "/" <> file) {
      Ok(content) -> {
        let html = jot.to_html(content)

        // TODO: parse title from content
        let title = basename

        dict.insert(pages, basename, Page(basename, title, html))
      }
      Error(_) -> {
        pages
      }
    }
  })
}

pub fn get_page(actor: PageServer, name: String) -> Result(Page, Nil) {
  actor.call(actor, GetPage(_, name), call_timeout)
}

pub fn list_page_routes(actor: PageServer) -> List(PageRoute) {
  actor.call(actor, ListPageRoutes(_), call_timeout)
}
