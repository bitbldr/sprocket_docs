import sprocket/context.{type Context}
import sprocket/component.{component, render}
import sprocket/html/elements.{
  a, a_text, article, code_text, div, h1, h2, p, p_text, span_text, text,
}
import sprocket/html/attributes.{class, href, target}
import docs/components/common.{alert, example}
import docs/components/codeblock.{CodeBlockProps, codeblock}
import docs/components/events_counter.{CounterProps, counter}

pub type HooksPageProps {
  HooksPageProps
}

pub fn hooks_page(ctx: Context, _props: HooksPageProps) {
  render(
    ctx,
    article([], [
      h1([], [text("Hooks")]),
      p([], [
        text(
          "Hooks are the essential mechanism that enable components to implement stateful logic, produce and consume side-effects,
                and couple a component to it's hierarchical context within the UI tree. They also make it easy to abstract and reuse
                stateful logic across different components.",
        ),
      ]),
      p([], [
        text(
          "Fundamentally, hooks are just higher order functions that are called from a stateful component which take the current
                context (and possibly other values) and provide a list of variables that can be used within the component. Internally,
                these function's can 'hook' into the component's lifecycle using this context and create the basis for stateful logic.
                For example, the ",
        ),
        code_text([], "state"),
        text(" hook provides a state variable and a setter function."),
      ]),
      component(
        codeblock,
        CodeBlockProps(
          language: "gleam",
          body: "
              pub fn example(ctx: Context, _props: ExampleProps) {

                use ctx, count, set_count <- state(ctx, 0)

                render(
                  ctx,
                  div([], [
                    text(\"The current state is \" <> int.to_string(count)),
                  ])
                )
              }
            ",
        ),
      ),
      p([], [
        text("Understanding the"),
        code_text([], "use"),
        text(
          " keyword and how higher order functions work in Gleam is necessary to fully understand the hook syntax. Check out the ",
        ),
        a([href("https://gleam.run/book/tour/use.html"), target("_blank")], [
          text("official Gleam documentation on "),
          code_text([], "use"),
          text(" expressions"),
        ]),
        text(" for more information."),
      ]),
      alert(common.Info, [
        div([], [
          span_text([class("font-bold")], "Note:"),
          text(
            " Hooks must be called in exactly the same order on every render and should be defined at the
            top of a component body. This means hooks cannot be called conditionally or within loops or
            nested functions.",
          ),
        ]),
      ]),
      p([], [
        text(
          "Sprocket provides a common set of native hooks that can be imported from the ",
        ),
        code_text([], "sprocket/hooks"),
        text(" module."),
      ]),
      component(
        codeblock,
        CodeBlockProps(
          language: "gleam",
          body: "
              import sprocket/hooks.{state, reducer, handler, effect, memo, callback, channel, provider, client}
            ",
        ),
      ),
      p_text(
        [],
        "We'll go over each of the native hooks and how to use them and also cover how to create custom hooks.",
      ),
      h2([], [text("State")]),
      p([], [
        text(
          "State hooks are used to manage a piece of state within a component. The current state along with a
          setter function are provided to the component. State is initialized to the value provided and can be
          updated by calling the setter function with the new value. State is maintained across renders but is
          reinitialized when a component is unmounted and remounted.",
        ),
      ]),
      component(
        codeblock,
        CodeBlockProps(
          language: "gleam",
          body: "
              use ctx, count, set_count <- state(ctx, 0)
            ",
        ),
      ),
      h2([], [text("Reducer")]),
      p([], [
        text(
          "Reducer hooks are used to manage more complex state. Similar to a state hook, a reducer
          will maintain the state across renders and be reinitialized when a component is mounted.
          However, a reducer is better for when state changes require complex transforms to a state
          model or when state logic needs to be abstracted out of a component module.",
        ),
      ]),
      p([], [
        text("Under the hood, a reducer hook is a lightweight "),
        a_text(
          [href("https://hexdocs.pm/gleam_otp/0.1.3/gleam/otp/acto")],
          "Gleam Actor",
        ),
        text(
          " OTP process (i.e. gen_server) and changes to the state (messages sent via dispatch) result in a
          re-render of the view.",
        ),
      ]),
      p_text(
        [],
        "For when an Elm or Redux architecture is preferred, a reducer hook should be used.",
      ),
      component(
        codeblock,
        CodeBlockProps(
          language: "gleam",
          body: "
              type Model =
                Int

              type Msg {
                Increment
                Decrement
                SetCount(Int)
                Reset
              }

              fn update(_model: Model, msg: Msg) -> Model {
                case msg {
                  Increment -> {
                    model + 1
                  }
                  Decrement -> {
                    model - 1
                  }
                  SetCount(count) -> count
                  Reset -> 0
                }
              }
            ",
        ),
      ),
      p([], [
        text(
          "The current model along with a dispatch function are provided. The model is initialized to the value
          provided and can be updated by calling the dispatch function with a message.",
        ),
      ]),
      component(
        codeblock,
        CodeBlockProps(
          language: "gleam",
          body: "
              use ctx, count, dispatch <- reducer(ctx, 0, update)
            ",
        ),
      ),
      p_text(
        [],
        "Reducer hooks allow state management to be refactored out of the component file and into a separate
        module. This can be useful for complex state management logic or message types that are shared across
        multiple components.",
      ),
      h2([], [text("Handler")]),
      p([], [
        text(
          "Handler hooks are used to create event handlers, They take a function and return an IdentifiableCallback.
          The IdentifiableCallback can be passed to an event handler attribute and ensures that event id's do not
          change across renders resulting in unnecessary diff patching. The callback will be called when the event
          is triggered and provide an optional CallbackParam depending on the event type.",
        ),
      ]),
      component(
        codeblock,
        CodeBlockProps(
          language: "gleam",
          body: "
              use ctx, increment <- handler(ctx, fn(_) {
                dispatch(Increment)
              })
            ",
        ),
      ),
      h2([], [text("Effect")]),
      p([], [
        text(
          "Effect hooks are used to perform side-effects. They take a function that is called on mount and when the
          trigger value changes. They can also specify an optional cleanup function as a return value.",
        ),
      ]),
      component(
        codeblock,
        CodeBlockProps(
          language: "gleam",
          body: "
              use ctx <- effect(
                ctx,
                fn(_) {
                  // Perform side-effects here

                  // Return a cleanup function if necessary
                  Some(fn(_) {
                    // Cleanup side-effects here
                  })
                },
                WithDeps([dep(some_value)]),
              )
            ",
        ),
      ),
      p([], [
        text("The "),
        code_text([], "WithDeps"),
        text(
          " trigger is used to specify a list of dependencies that will cause the effect function to be called again
          when any of the dependencies change. If an empty list is provided, the effect function will only be called
          on mount.",
        ),
      ]),
      h2([], [text("Memo")]),
      p([], [
        text(
          "Memo hooks are used to memoize a computed value. They take a function and a list of dependencies and
          return a memoized value. The memoized value will only be re-evaluated when the dependencies change.",
        ),
      ]),
      component(
        codeblock,
        CodeBlockProps(
          language: "gleam",
          body: "
              use ctx, memoized_value <- memo(ctx, fn() { expensive_fn() }, WithDeps([dep(some_value)]))
            ",
        ),
      ),
      h2([], [text("Callback")]),
      p([], [
        text(
          "Callback hooks are used to memoize a function. They take a function and a list of dependencies and return
          a memoized function. The memoized function will only be re-evaluated when the dependencies change.",
        ),
      ]),
      component(
        codeblock,
        CodeBlockProps(
          language: "gleam",
          body: "
              use ctx, memoized_fn <- callback(ctx, some_fn, WithDeps([dep(some_value)]))
            ",
        ),
      ),
      h2([], [text("Provider")]),
      p_text(
        [],
        "
        Provider hooks are used to access some data from a parent or ancestor component in the UI tree.
        The hook takes a provider key and returns the value provided by the ancestor. It is useful
        for providing global state or some slice of data to a component without having to pass it down
        through the component tree, sometimes known as \"prop drilling\".
        ",
      ),
      p([], [
        text("This hook is conceptually similar to the "),
        code_text([], "useContext"),
        text(" hook in React."),
      ]),
      component(
        codeblock,
        CodeBlockProps(
          language: "gleam",
          body: "
              use ctx, current_user <- provider(ctx, \"user\")
            ",
        ),
      ),
      p_text(
        [],
        "
          Because the provider key is a global identifier, it is important to use a unique key to avoid collisions with
          other providers. The key should be a string that is unique to the data being provided and if used in a
          library then it is recommened that it be namespaced to avoid conflicts with other keys within the application.
        ",
      ),
      h2([], [text("Client")]),
      p([], [
        text(
          "Client hooks are a special type of hook that enable a component to implement logic on the client.",
        ),
      ]),
      p([], [
        text(
          "
                  We can expand the ",
        ),
        code_text([], "display"),
        text(" component to accept another optional prop called "),
        code_text([], "on_reset"),
        text(
          " which will reset the count and re-render the component when the ",
        ),
        code_text([], "display"),
        text(" component is double-clicked."),
      ]),
      component(
        codeblock,
        CodeBlockProps(
          language: "gleam",
          body: "
              pub type DisplayProps {
                DisplayProps(count: Int, on_reset: Option(fn() -> Nil))
              }

              pub fn display(ctx: Context, props: DisplayProps) {
                let DisplayProps(count: count, on_reset: on_reset) = props

                use ctx, doubleclick_client, _doubleclick_client_dispatch <- client(
                  ctx,
                  \"DoubleClick\",
                  Some(fn(msg, _payload, _dispatch) {
                    case msg {
                      \"doubleclick\" -> {
                        case on_reset {
                          Some(on_reset) -> on_reset()
                          None -> Nil
                        }
                      }
                      _ -> Nil
                    }
                  }),
                )

                render(
                  ctx,
                  span(
                    [
                      doubleclick_client(),
                      class(
                        \"p-1 px-2 w-10 bg-white dark:bg-gray-900 border-t border-b dark:border-gray-500 align-center text-center\",
                      ),
                    ],
                    [text(int.to_string(count))],
                  ),
                )
              }
            ",
        ),
      ),
      p([], [
        text(
          "We also need to implement some JavaScript to handle the double-click event on the client and send a message to the server.",
        ),
      ]),
      component(
        codeblock,
        CodeBlockProps(
          language: "typescript",
          body: "
              import { connect } from 'sprocket-js';

              const hooks = {
                DoubleClick: {
                  mounted({ el, pushEvent }) {
                    el.addEventListener('dblclick', () => {
                      pushEvent('doubleclick', {});
                    });
                  },
                },
              };

              ...

              connect(livePath, {
                csrfToken,
                hooks,
              });
            ",
        ),
      ),
      example([component(counter, CounterProps(enable_reset: True))]),
      h2([], [text("Custom Hooks")]),
      p([], [
        text(
          "Hooks can be combined to create custom hooks. For example, we can refactor our doubleclick client hook
          logic to create a reusable custom hook.",
        ),
      ]),
      component(
        codeblock,
        CodeBlockProps(
          language: "gleam",
          body: "
              pub fn doubleclick(ctx: Context, on_doubleclick: fn() -> Nil, cb) {
                use ctx, handle_doubleclick, _doubleclick_client_dispatch <- client(
                  ctx,
                  \"DoubleClick\",
                  Some(fn(msg, _payload, _dispatch) {
                    case msg {
                      \"doubleclick\" -> {
                        on_doubleclick()
                      }
                      _ -> Nil
                    }
                  }),
                )

                cb(ctx, handle_doubleclick)
              }
            ",
        ),
      ),
      p([], [
        text("To use the "),
        code_text([], "doubleclick"),
        text(
          " hook, we can call it within a component as we normally would a native hook",
        ),
      ]),
      component(
        codeblock,
        CodeBlockProps(
          language: "gleam",
          body: "
              pub fn display(ctx: Context, props: DisplayProps) {
                let DisplayProps(count: count, on_reset: on_reset) = props

                use ctx, handle_doubleclick <- doubleclick(ctx, fn() { dispatch(Reset) }})

                render(
                  ctx,
                  span(
                    [
                      handle_doubleclick(),
                      class(
                        \"p-1 px-2 w-10 bg-white dark:bg-gray-900 border-t border-b dark:border-gray-500 align-center text-center\",
                      ),
                    ],
                    [text(int.to_string(count))],
                  ),
                )
              }
            ",
        ),
      ),
    ]),
  )
}
