import sprocket/context.{type Context}
import sprocket/component.{component, render}
import sprocket/html/elements.{article, code_text, h1, h2, p, text}
import docs/components/hello_button.{HelloButtonProps, hello_button}
import docs/components/common.{example}
import docs/components/codeblock.{CodeBlockProps, codeblock}

pub type StateManagementPageProps {
  StateManagementPageProps
}

pub fn state_management_page(ctx: Context, _props: StateManagementPageProps) {
  render(
    ctx,
    article(
      [],
      [
        h1([], [text("State Management")]),
        p(
          [],
          [
            text(
              "State is managed using stateful components and hooks. We previously saw how to create a simple state variable using the ",
            ),
            code_text([], "state"),
            text(" hook. Here we will take a look at using the "),
            code_text([], "reducer"),
            text(
              " hook to model more complex state and transformations. We'll also utilize the ",
            ),
            code_text([], "handler"),
            text(" hook to help us dispatch events to the reducer."),
          ],
        ),
        h2([], [text("Reducer Functions")]),
        p(
          [],
          [
            text(
              "Reducer functions are functions that take a state and message and return a new state. They are used to update state in response to events. Let's create a ",
            ),
            code_text([], "hello_button"),
            text(
              " component as an example, we can define a function that updates the state when the button is clicked.",
            ),
          ],
        ),
        p([], [text("First we define our state struct and message types:")]),
        component(
          codeblock,
          CodeBlockProps(
            language: "gleam",
            body: "
              type Model {
                Model(selection: Option(Int), options: List(HelloOption))
              }

              type Msg {
                NoOp
                SayHello
              }
            ",
          ),
        ),
        p(
          [],
          [
            text(
              "Here we're storing a list of options and the index of the selected option in the state.",
            ),
          ],
        ),
        p([], [text("Next we define our update function:")]),
        component(
          codeblock,
          CodeBlockProps(
            language: "gleam",
            body: "
              fn update(model: Model, msg: Msg) -> Model {
                case msg {
                  NoOp -> model
                  SayHello ->
                    Model(..model, selection: Some(int.random(0, list.length(model.options))))
                }
              }
            ",
          ),
        ),
        p(
          [],
          [
            text(
              "An update function takes the current state and a message and returns a new state.",
            ),
          ],
        ),
        h2([], [text("Introducing the Reducer Hook")]),
        p(
          [],
          [
            text("Let's declare a "),
            code_text([], "reducer"),
            text(
              " hook in our component that initializes the state model and uses our update function:",
            ),
          ],
        ),
        component(
          codeblock,
          CodeBlockProps(
            language: "gleam",
            body: "
              use ctx, Model(selection: selection, options: options), dispatch <- reducer(
                ctx,
                initial(hello_options()),
                update,
              )
            ",
          ),
        ),
        p(
          [],
          [
            text(
              "You can see here we are provided with the current state of the reducer, which we can use in our component. ",
            ),
            text("Notice, we also are provided with a "),
            code_text([], "dispatch"),
            text(
              " function from the reducer. The dispatch function is used to send messages to the reducer which will update the state and trigger a re-render.",
            ),
          ],
        ),
        p(
          [],
          [
            text("The function call to "),
            code_text([], "initial"),
            text(" here returns an initial "),
            code_text([], "Model"),
            text(" using the predefined set options from "),
            code_text([], "hello_options"),
            text(
              " which is used to initialize the state of the reducer when the component is mounted.",
            ),
          ],
        ),
        p(
          [],
          [
            text(
              "We need one more thing to complete our component. We need to define a function that will be called when the button is clicked. It's important that we create an ",
            ),
            code_text([], "IdentifiableHandler"),
            text(" by using the "),
            code_text([], "handler"),
            text(
              " hook so that we can ensure the id of the handler function is consistent across renders, preventing a new id being created and sent to the client on every render.",
            ),
          ],
        ),
        component(
          codeblock,
          CodeBlockProps(
            language: "gleam",
            body: "
              use ctx, on_hello_button <- handler(
                ctx,
                fn(_) { dispatch(SayHello) },
              )
            ",
          ),
        ),
        h2([], [text("Putting it all together")]),
        p(
          [],
          [
            text(
              "We now have all the pieces we need to create a more interesting button that updates whenever it is clicked. Let's put it all together:",
            ),
          ],
        ),
        component(
          codeblock,
          CodeBlockProps(
            language: "gleam",
            body: "
              import gleam/int
              import gleam/list
              import gleam/pair
              import gleam/option.{None, Option, Some}
              import sprocket/context.{Context, WithDeps}
              import sprocket/component.{render}
              import sprocket/hooks.{State, reducer, handler}
              import sprocket/html/elements.{button, div, span, text}
              import sprocket/html/attributes.{class, on_click}

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
                    Model(..model, selection: Some(int.random(0, list.length(model.options))))
                }
              }

              pub type HelloButtonProps {
                HelloButtonProps
              }

              pub fn hello_button(ctx: Context, _props: HelloButtonProps) {
                use ctx, Model(selection: selection, options: options), dispatch <- reducer(
                  ctx,
                  Model(selection: None, options: hello_options()),
                  update,
                )

                use ctx, on_hello_button <- handler(
                  ctx,
                  fn(_) { dispatch(SayHello) },
                )

                // find the selected option using the selection index and list of options
                let hello =
                  selection
                  |> option.map(fn(i) {
                    list.at(options, i)
                    |> option.from_result()
                  })
                  |> option.flatten()

                render(
                  ctx,
                  div(
                    [],
                    [
                      button(
                        [
                          class(\"p-2 bg-blue-500 hover:bg-blue-600 active:bg-blue-700 text-white rounded\"),
                          on_click(on_hello_button),
                        ],
                        [text(\"Say Hello!\")],
                      ),
                      ..case hello {
                        None -> []
                        Some(hello) -> [
                          span([class(\"ml-2\")], [text(pair.second(hello))]),
                          span(
                            [class(\"ml-2 text-gray-400 bold\")],
                            [text(pair.first(hello))],
                          ),
                        ]
                      }
                    ],
                  ),
                )
              }

              type HelloOption =
                #(String, String)

              fn hello_options() -> List(HelloOption) {
                [
                  #(\"English\", \"Hello\"),
                  #(\"Spanish\", \"Hola\"),
                  #(\"French\", \"Bonjour\"),
                  #(\"German\", \"Hallo\"),
                  #(\"Italian\", \"Ciao\"),
                  #(\"Portuguese\", \"Olá\"),
                  #(\"Hawaiian\", \"Aloha\"),
                  #(\"Chinese (Mandarin)\", \"你好,(Nǐ hǎo)\"),
                  #(\"Japanese\", \"こんにち, (Konnichiwa)\"),
                  #(\"Korean\", \"안녕하세, (Annyeonghaseyo)\"),
                  #(\"Arabic\", \"مرحب, (Marhaba)\"),
                  #(\"Hindi\", \"नमस्त, (Namaste)\"),
                  #(\"Turkish\", \"Merhaba\"),
                  #(\"Dutch\", \"Hallo\"),
                  #(\"Swedish\", \"Hej\"),
                  #(\"Norwegian\", \"Hei\"),
                  #(\"Danish\", \"Hej\"),
                  #(\"Greek\", \"Γεια σας,(Yia sas)\"),
                  #(\"Polish\", \"Cześć\"),
                  #(\"Swahili\", \"Hujambo\"),
                ]
              }
            ",
          ),
        ),
        example([component(hello_button, HelloButtonProps)]),
        p(
          [],
          [
            text(
              "We now have a functional button that says hello in a different language when it's clicked.",
            ),
          ],
        ),
        p(
          [],
          [
            text(
              "Remember, all of these state changes are happening on the server. Events are being passed from the client to the server, the latest view is rendered and a minimal diff update is sent back to the client a which is then patched into the DOM!",
            ),
          ],
        ),
        p(
          [],
          [
            text(
              "These are just two of the hooks that are available in Sprocket. There are many more to explore! We'll cover hooks more in-depth in the next section.",
            ),
          ],
        ),
      ],
    ),
  )
}
