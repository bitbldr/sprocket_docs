import sprocket/context.{Context}
import sprocket/component.{component, render}
import sprocket/html/elements.{
  a_text, article, code_text, h1, h2, p, p_text, text,
}
import sprocket/html/attributes.{href, target}
import docs/components/common.{codeblock, example}
import docs/components/events_counter.{CounterProps, counter}

pub type HooksPageProps {
  HooksPageProps
}

pub fn hooks_page(ctx: Context, _props: HooksPageProps) {
  render(
    ctx,
    [
      article(
        [],
        [
          h1([], [text("Hooks")]),
          p(
            [],
            [
              text(
                "Hooks are the essential mechanism that enable components to implement stateful logic, produce and consume side-effects,
                and couple a component to it's hierarchical context within the UI tree. They also make it easy to abstract and reuse
                stateful logic across different components.",
              ),
            ],
          ),
          p(
            [],
            [
              text(
                "At their core, hooks are higher order functions that are called from a stateful component which take the current context (and possibly other values) and provide a list of values that can be used within the component. For example, the ",
              ),
              code_text([], "state"),
              text(" hook provides the current state and a setter function."),
            ],
          ),
          codeblock(
            "gleam",
            "
            pub fn example(ctx: Context, props: ExampleProps) {
              let ExampleProps(...) = props

              use ctx, count, set_count <- state(ctx, 0)

              render(
                ctx,
                [
                  div([], [
                    text(\"The current state is \" <> int.to_string(count)),
                  ])
                ],
              )
            }
            ",
          ),
          p(
            [],
            [
              text("Understanding how the"),
              code_text([], "use"),
              text(
                " keyword and higher order functions work in Gleam is necessary to fully understand hooks. Check out the ",
              ),
              a_text(
                [href("https://gleam.run/book/tour/use.html"), target("_blank")],
                "official Gleam documentation on Use expressions",
              ),
              text(" for more information."),
            ],
          ),
          p(
            [],
            [
              text(
                "Sprocket provides a common set of native hooks that can be imported from the ",
              ),
              code_text([], "sprocket/hooks"),
              text(" module."),
            ],
          ),
          codeblock(
            "gleam",
            "
            import sprocket/hooks.{state, reducer, callback, effect, memo, channel, context, params, portal, client}
            ",
          ),
          p_text(
            [],
            "We'll go over each of the native hooks and how to use them and also cover how to create custom hooks.",
          ),
          h2([], [text("State Hooks")]),
          p(
            [],
            [
              text(
                "State hooks are used to manage state within a component. The current state along with a setter function are provided to the component. State is initialized to the value provided and can be updated by calling the setter function with the new value. State is maintained across renders but is reinitialized when a component is unmounted and remounted.",
              ),
            ],
          ),
          codeblock(
            "gleam",
            "
            use ctx, count, set_count <- state(ctx, 0)
            ",
          ),
          h2([], [text("Reducer Hooks")]),
          p(
            [],
            [
              text(
                "Reducer hooks are used to manage more complex state, which can be referred to as a model. Similar to the State hook, a reducer will maintain the state across renders and be reinitialized when a component is mounted. However, a reducer is better for when state changes require complex transforms to a state model or if an Elm or Redux architecture are preferred.",
              ),
            ],
          ),
          codeblock(
            "gleam",
            "
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
          p(
            [],
            [
              text(
                "The current model along with a dispatch function are provided. The model is initialized to the value provided and can be updated by calling the dispatch function with a message.",
              ),
            ],
          ),
          codeblock(
            "gleam",
            "
                use ctx, count, dispatch <- reducer(ctx, 0, update)
                ",
          ),
          p_text(
            [],
            "Reducer hooks allow state management to be refactored out of the component file and into a separate module. This can be useful for complex state management logic or message types that are shared across multiple components.",
          ),
          h2([], [text("Callback Hooks")]),
          p(
            [],
            [
              text(
                "Callback hooks are used to create identifiable callbacks which remain consistent across renders, minimizing unnecessary id changes in diff patches. Most event handler attributes require an ",
              ),
              code_text([], "IdentifiableCallback"),
              text(" and therefore must use a callback hook."),
            ],
          ),
          codeblock(
            "gleam",
            "
              use ctx, increment <- callback(
                ctx,
                fn(_) { dispatch(SetCount(count + 1)) },
                WithDeps([dep(count)]),
              )

              use ctx, reset <- callback(
                ctx,
                fn(_) { dispatch(Reset) },
                WithDeps([]),
              )

              render(
                ctx,
                [
                  span([], [text(int.to_string(count))]),
                  button([on_click(increment)], [text(\"+\")]),
                  button([on_click(reset)], [text(\"Reset\")]),
                ],
              )
              )
            ",
          ),
          h2([], [text("Effect Hooks")]),
          p(
            [],
            [
              text(
                "Effect hooks are used to perform side-effects. They take a function that is called on mount and when the trigger value changes and can specify an optional cleanup function as a return value.",
              ),
            ],
          ),
          codeblock(
            "gleam",
            "
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
          p(
            [],
            [
              text("The "),
              code_text([], "WithDeps"),
              text(
                " trigger is used to specify a list of dependencies that will cause the effect function to be called again when any of the dependencies change. If an empty list is provided, the effect function will only be called on mount.",
              ),
            ],
          ),
          h2([], [text("Memo Hooks")]),
          p([], [text("COMING SOON")]),
          h2([], [text("Channel Hooks")]),
          p([], [text("COMING SOON")]),
          h2([], [text("Context Hooks")]),
          p([], [text("COMING SOON")]),
          h2([], [text("Params Hooks")]),
          p([], [text("COMING SOON")]),
          h2([], [text("Portal Hooks")]),
          p([], [text("COMING SOON")]),
          h2([], [text("Client Hooks")]),
          p(
            [],
            [
              text(
                "Client hooks are a special type of hook that enable a component to implement logic on the client.",
              ),
            ],
          ),
          p(
            [],
            [
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
            ],
          ),
          codeblock(
            "gleam",
            "
            pub type DisplayProps {
              DisplayProps(count: Int, on_reset: Option(fn() -> Nil))
            }

            pub fn display(ctx: Context, props: DisplayProps) {
              let DisplayProps(count: count, on_reset: on_reset) = props

              use ctx, client_doubleclick, _client_doubleclick_dispatch <- client(
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
                [
                  span(
                    [
                      client_doubleclick(),
                      class(
                        \"p-1 px-2 w-10 bg-white dark:bg-gray-900 border-t border-b dark:border-gray-500 align-center text-center\",
                      ),
                    ],
                    [text(int.to_string(count))],
                  ),
                ],
              )
            }
            ",
          ),
          p(
            [],
            [
              text(
                "We also need to implement some JavaScript to handle the double-click event on the client and send a message to the server.",
              ),
            ],
          ),
          codeblock(
            "javascript",
            "
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
          example([component(counter, CounterProps(enable_reset: True))]),
          h2([], [text("Custom Hooks")]),
          p(
            [],
            [
              text(
                "Hooks can be combined to create custom hooks. For example, we can refactor our doubleclick client hook logic to create a reusable custom hook.",
              ),
            ],
          ),
          codeblock(
            "gleam",
            "
            pub fn double_click(ctx: Context, on_double_click: fn() -> Nil, cb) {
              use ctx, client_doubleclick, _client_doubleclick_dispatch <- client(
                ctx,
                \"DoubleClick\",
                Some(fn(msg, _payload, _dispatch) {
                  case msg {
                    \"doubleclick\" -> {
                      on_double_click()
                    }
                    _ -> Nil
                  }
                }),
              )

              cb(ctx, client_doubleclick)
            }

            ",
          ),
          p(
            [],
            [
              text("To use the "),
              code_text([], "double_click"),
              text(
                " hook, we can call it within a component as we normally would a native hook",
              ),
            ],
          ),
          codeblock(
            "gleam",
            "
            pub fn display(ctx: Context, props: DisplayProps) {
              let DisplayProps(count: count, on_reset: on_reset) = props

              use ctx, client_doubleclick <- double_click(ctx, fn() { dispatch(Reset) }})

              render(
                ctx,
                [
                  span(
                    [
                      client_doubleclick(),
                      class(
                        \"p-1 px-2 w-10 bg-white dark:bg-gray-900 border-t border-b dark:border-gray-500 align-center text-center\",
                      ),
                    ],
                    [text(int.to_string(count))],
                  ),
                ],
              )
            }
            ",
          ),
        ],
      ),
    ],
  )
}
