import sprocket/context.{type Context}
import sprocket/component.{component, render}
import sprocket/html/elements.{article, code_text, h1, p, span_text, text}
import sprocket/html/attributes.{class}
import docs/components/common.{example}
import docs/components/codeblock.{CodeBlockProps, codeblock}
import docs/components/events_counter.{CounterProps, counter}

pub type PropsAndEventsPageProps {
  PropsAndEventsPageProps
}

pub fn props_and_events_page(ctx: Context, _props: PropsAndEventsPageProps) {
  render(
    ctx,
    article([], [
      h1([], [text("Props and Events")]),
      p([], [
        text(
          "
                  Props and events are used by components to communicate with each other. Props are how components communicate
                  with their children, and events are how components communicate with their parents in the component hierarchy.
                ",
        ),
      ]),
      p([], [
        text(
          "
                  Props are passed to components as arguments to the component function. Event callbacks are
                  are also passed to components as props in the form of a function. The component
                  can then call the event callback when an event occurs, notifying the parent.
                ",
        ),
      ]),
      p([], [
        text(
          "Let's take a look at how props and events work in a functional example. In this example, the ",
        ),
        code_text([], "counter"),
        text(" component is passing a prop called "),
        code_text([], "on_click"),
        text(" to the two "),
        code_text([], "button"),
        text(
          "
                    components. The ",
        ),
        code_text([], "counter"),
        text(" component is also passing a prop called "),
        code_text([], "count"),
        text(" to the "),
        code_text([], "display"),
        text(
          " component.
                ",
        ),
        text(
          "
                    When the ",
        ),
        code_text([], "button"),
        text(" components are clicked, they call the "),
        code_text([], "on_click"),
        text(
          " event handler that was passed to them
                    as a prop. The ",
        ),
        code_text([], "counter"),
        text(" component then increments its "),
        code_text([], "count"),
        text(" state and re-renders. The "),
        code_text([], "display"),
        text(
          " component
                    is also re-rendered because its ",
        ),
        code_text([], "count"),
        text(
          " prop has changed.
                ",
        ),
      ]),
      component(
        codeblock,
        CodeBlockProps(
          language: "gleam",
          body: "
            import gleam/int
            import gleam/option.{None, Option, Some}
            import sprocket/context.{Context, WithDeps, dep}
            import sprocket/hooks.{reducer, handler}
            import sprocket/component.{component, render}
            import sprocket/html/elements.{div, span, text}
            import sprocket/html/attributes.{class, classes}

            type Model =
              Int

            type Msg {
              UpdateCounter(Int)
              ResetCounter
            }

            fn update(_model: Model, msg: Msg) -> Model {
              case msg {
                UpdateCounter(count) -> {
                  count
                }
                ResetCounter -> 0
              }
            }

            pub type CounterProps {
              CounterProps
            }

            pub fn counter(ctx: Context, _props: CounterProps) {
              // Define a reducer to handle events and update the state
              use ctx, count, dispatch <- reducer(ctx, 0, update)

              render(
                ctx,
                div(
                  [class(\"flex flex-row m-4\")],
                  [
                    component(
                      button,
                      StyledButtonProps(
                        class: \"rounded-l\",
                        label: \"-\",
                        on_click: fn() { dispatch(UpdateCounter(count - 1)) },
                      ),
                    ),
                    component(
                      display,
                      DisplayProps(count: count),
                    ),
                    component(
                      button,
                      StyledButtonProps(
                        class: \"rounded-r\",
                        label: \"+\",
                        on_click: fn() { dispatch(UpdateCounter(count + 1)) },
                      ),
                    ),
                  ],
                ),
              )
            }

            pub type ButtonProps {
              ButtonProps(label: String, on_click: fn() -> Nil)
              StyledButtonProps(class: String, label: String, on_click: fn() -> Nil)
            }

            pub fn button(ctx: Context, props: ButtonProps) {
              // here we unpack the different types of ButtonProps that can be passed to the button component
              let #(class, label, on_click) = case props {
                ButtonProps(label, on_click) -> #(None, label, on_click)
                StyledButtonProps(class, label, on_click) -> #(Some(class), label, on_click)
              }

              use ctx, handle_click <- handler(
                ctx,
                fn(_) { on_click() },
              )

              render(
                ctx,
                html.button_text(
                  [
                    attributes.on_click(handle_click),
                    classes([
                      class,
                      Some(
                        \"p-1 px-2 border dark:border-gray-500 bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 active:bg-gray-300 dark:active:bg-gray-600\",
                      ),
                    ]),
                  ],
                  label,
                ),
              )
            }

            pub type DisplayProps {
              DisplayProps(count: Int)
            }

            pub fn display(ctx: Context, props: DisplayProps) {
              let DisplayProps(count: count) = props

              render(
                ctx,
                span(
                  [
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
      example([component(counter, CounterProps(enable_reset: False))]),
      p([], [
        text("So "),
        span_text([class("font-bold")], "state flows down"),
        text(" the component tree while "),
        span_text([class("font-bold")], "events bubble up"),
        text(
          ".
                We'll cover state management more in-depth in the next section, but it's useful to start thinking about how this data-flow will inform
                where state should live in your component hierarchy. And since we have the safety provided by the Gleam type system,
                we aren't afraid of refactoring our state to a different part of the hierarchy when our requirements or designs inevitably change!",
        ),
      ]),
    ]),
  )
}
