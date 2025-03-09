import docs/utils/list.{element_at} as _
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import sprocket/component.{type Context, render}
import sprocket/hooks.{type Cmd, reducer}
import sprocket/html/attributes.{class}
import sprocket/html/elements.{
  button, div, fragment, keyed, span, span_text, text,
}
import sprocket/html/events

type Model {
  Model(selection: Option(Greeting), options: List(Greeting))
}

type Msg {
  NoOp
  NextGreeting
  Greet(Greeting)
  Reset
}

fn init(options: List(Greeting)) -> #(Model, List(Cmd(Msg))) {
  #(Model(selection: None, options:), [])
}

fn update(model: Model, msg: Msg) {
  case msg {
    NoOp -> #(model, [])
    NextGreeting -> #(model, [new_random_selection(model.options)])
    Greet(selection) -> {
      let options = model.options |> list.filter(fn(o) { o != selection })

      #(Model(selection: Some(selection), options:), [])
    }
    Reset -> init(greetings())
  }
}

fn new_random_selection(options) -> Cmd(Msg) {
  fn(dispatch) {
    let selection =
      options
      |> list.length()
      |> int.random()
      |> element_at(options, _, 0)

    case selection {
      Ok(selection) -> dispatch(Greet(selection))
      Error(_) -> Nil
    }
  }
}

pub type GreetingButtonProps {
  GreetingButtonProps
}

pub fn greeting_button(ctx: Context, _props: GreetingButtonProps) {
  use ctx, Model(selection:, options:), dispatch <- reducer(
    ctx,
    init(greetings()),
    update,
  )

  let say_hello = fn(_) { dispatch(NextGreeting) }
  let reset = fn(_) { dispatch(Reset) }

  let num_options_left = list.length(options)

  render(
    ctx,
    div([], [
      case options {
        [] ->
          keyed(
            "reset",
            button(
              [
                class(
                  "p-2 text-blue-500 hover:text-blue-600 hover:underline active:text-blue-700",
                ),
                events.on_click(reset),
              ],
              [text("Reset")],
            ),
          )
        _ ->
          keyed(
            "greet",
            button(
              [
                class(
                  "p-2 bg-blue-500 hover:bg-blue-600 active:bg-blue-700 text-white rounded",
                ),
                events.on_click(say_hello),
              ],
              [
                text("Say Hello!"),
                case num_options_left < 5 {
                  True ->
                    span_text(
                      [class("rounded bg-white text-blue-500 px-1 ml-2")],
                      int.to_string(num_options_left) <> " left",
                    )
                  False -> fragment([])
                },
              ],
            ),
          )
      },
      ..case selection {
        None -> []
        Some(hello) -> [
          span([class("ml-2")], [text(hello.1)]),
          span([class("ml-2 text-gray-400 bold")], [text(hello.0)]),
        ]
      }
    ]),
  )
}

type Greeting =
  #(String, String)

fn greetings() -> List(Greeting) {
  [
    #("English", "Hello"),
    #("Spanish", "Hola"),
    #("French", "Bonjour"),
    #("German", "Hallo"),
    #("Italian", "Ciao"),
    #("Portuguese", "Olá"),
    #("Hawaiian", "Aloha"),
    #("Chinese (Mandarin)", "你好,(Nǐ hǎo)"),
    #("Japanese", "こんにち, (Konnichiwa)"),
    #("Korean", "안녕하세, (Annyeonghaseyo)"),
    #("Arabic", "مرحب, (Marhaba)"),
    #("Hindi", "नमस्त, (Namaste)"),
    #("Turkish", "Merhaba"),
    #("Dutch", "Hallo"),
    #("Swedish", "Hej"),
    #("Norwegian", "Hei"),
    #("Danish", "Hej"),
    #("Greek", "Γεια σας,(Yia sas)"),
    #("Polish", "Cześć"),
    #("Swahili", "Hujambo"),
  ]
}
