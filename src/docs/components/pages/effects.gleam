import gleam/option.{None, Some}
import sprocket/context.{type Context}
import sprocket/component.{component, render}
import sprocket/html/elements.{article, code_text, h1, p, p_text, text}
import docs/components/codeblock.{CodeBlockProps, codeblock}
import docs/components/clock.{ClockProps, clock}
import docs/components/common.{example}

pub type EffectsPageProps {
  EffectsPageProps
}

pub fn effects_page(ctx: Context, _props: EffectsPageProps) {
  render(
    ctx,
    article([], [
      h1([], [text("Effects")]),
      p([], [
        text(
          "
        The ",
        ),
        code_text([], "effect"),
        text(
          "hook is a way to perform side effects according to a component's lifecycle,
          such as synchronizing with an external system. The
          effect is executed according to the triggers defined in the effect
          hook and can optionally specify a cleanup function. ",
        ),
      ]),
      p([], [
        text("For example, an effect hook that triggers"),
        code_text([], "OnMount"),
        text(
          " will run when the component is first mounted. A hook that triggers ",
        ),
        code_text([], "WithDeps([..])"),
        text(
          " will run when the component is first mounted and whenever the dependencies specified change.
          ",
        ),
      ]),
      p_text(
        [],
        "Let's take a look at an example of a clock component that uses an effect hook to update the time every second.",
      ),
      component(
        codeblock,
        CodeBlockProps(
          language: "gleam",
          body: "
            import gleam/io
            import gleam/erlang
            import gleam/option.{type Option, None, Some}
            import sprocket/context.{type Context, WithDeps, dep}
            import sprocket/component.{render}
            import sprocket/hooks.{effect, reducer}
            import sprocket/html/elements.{fragment, span, text}
            import sprocket/internal/utils/timer.{interval}

            type Model {
              Model(time: Int, timezone: String)
            }

            type Msg {
              UpdateTime(Int)
            }

            fn update(model: Model, msg: Msg) -> Model {
              case msg {
                UpdateTime(time) -> {
                  Model(..model, time: time)
                }
              }
            }

            fn initial() -> Model {
              Model(time: erlang.system_time(erlang.Second), timezone: \"UTC\")
            }

            pub type ClockProps {
              ClockProps(label: Option(String), time_unit: Option(erlang.TimeUnit))
            }

            pub fn clock(ctx: Context, props: ClockProps) {
              let ClockProps(label, time_unit) = props

              // Define a reducer to handle events and update the state
              use ctx, Model(time: time, ..), dispatch <- reducer(ctx, initial(), update)

              // Example effect with an empty list of dependencies, runs once on mount
              use ctx <- effect(
                ctx,
                fn() {
                  io.println(\"Clock component mounted!\")
                  None
                },
                WithDeps([]),
              )

              let time_unit =
                time_unit
                |> option.unwrap(erlang.Second)

              // Example effect that has a cleanup function and runs whenever `time` or `time_unit` changes
              use ctx <- effect(
                ctx,
                fn() {
                  let interval_duration = case time_unit {
                    erlang.Millisecond -> 1
                    _ -> 1000
                  }

                  let update_time = fn() {
                    dispatch(UpdateTime(erlang.system_time(time_unit)))
                  }

                  let cancel = interval(interval_duration, update_time)

                  Some(fn() { cancel() })
                },
                WithDeps([dep(time), dep(time_unit)]),
              )

              let current_time = format_time(time, \"%y-%m-%d %I:%M:%S %p\", time_unit)

              render(ctx, case label {
                Some(label) ->
                  fragment([span([], [text(label)]), span([], [text(current_time)])])
                None -> fragment([text(current_time)])
              })
            }
          ",
        ),
      ),
      example([
        component(
          clock,
          ClockProps(label: Some("The current time is: "), time_unit: None),
        ),
      ]),
    ]),
  )
}
