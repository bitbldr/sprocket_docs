import docs/utils/list.{element_at} as _
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import sprocket/component.{render}
import sprocket/context.{type Context}
import sprocket/hooks.{handler, reducer}
import sprocket/html/attributes.{class, on_click}
import sprocket/html/elements.{button, div, span, text}

type Model {
  Model(selection: Option(Int), options: List(HelloOption))
}

type Msg {
  NoOp
  SayHello
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    NoOp -> model
    SayHello ->
      Model(..model, selection: Some(int.random(list.length(model.options))))
  }
}

fn initial(options: List(HelloOption)) -> Model {
  Model(selection: None, options: options)
}

pub type HelloButtonProps {
  HelloButtonProps
}

pub fn hello_button(ctx: Context, _props: HelloButtonProps) {
  use ctx, Model(selection: selection, options: options), dispatch <- reducer(
    ctx,
    initial(hello_strings()),
    update,
  )

  use ctx, on_say_hello <- handler(ctx, fn(_) { dispatch(SayHello) })

  let hello =
    selection
    |> option.map(fn(i) {
      element_at(options, i, 0)
      |> option.from_result()
    })
    |> option.flatten()

  render(
    ctx,
    div([], [
      button(
        [
          class(
            "p-2 bg-blue-500 hover:bg-blue-600 active:bg-blue-700 text-white rounded",
          ),
          on_click(on_say_hello),
        ],
        [text("Say Hello!")],
      ),
      ..case hello {
        None -> []
        Some(hello) -> [
          span([class("ml-2")], [text(hello.1)]),
          span([class("ml-2 text-gray-400 bold")], [text(hello.0)]),
        ]
      }
    ]),
  )
}

type HelloOption =
  #(String, String)

fn hello_strings() -> List(HelloOption) {
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
