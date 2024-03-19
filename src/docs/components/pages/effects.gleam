import gleam/option.{None}
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
        "Let's take a look at an example of a clock component that uses an effect hook to start a timer and
        update the time every second.",
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

              let current_time = format_utc_timestamp(time, time_unit)

              render(ctx, case label {
                Some(label) ->
                  fragment([span([], [text(label)]), span([], [text(current_time)])])
                None -> fragment([text(current_time)])
              })
            }

            @external(erlang, \"print_time\", \"format_utc_timestamp\")
            pub fn format_utc_timestamp(time: ErlangTimestamp, unit: erlang.TimeUnit) -> String
          ",
        ),
      ),
      p([], [
        text(
          "We can also use a bit of erlang code here to handle formatting the timestamp, which demonstrates
          how easy it is to call some erlang functionality from Gleam using FFI. Using the ",
        ),
        code_text([], "@external"),
        text(
          " attribute, we can declare typed erlang interfaces in our Gleam code. In this case, we're calling the ",
        ),
        code_text([], "format_utc_timestamp"),
        text(" function defined in our "),
        code_text([], "print_time"),
        text(
          " module. This function takes an erlang timestamp and a time unit and returns a formatted string.
          The erlang code for this module is shown below.",
        ),
      ]),
      component(
        codeblock,
        CodeBlockProps(
          language: "erlang",
          body: "
            -module(print_time).
            -export([format_utc_timestamp/2]).

            format_utc_timestamp(Timestamp, Unit) ->
                {_, _, Micro} = Timestamp,
                {{Year, Month, Day}, {Hour, Minute, Second}} = calendar:now_to_universal_time(Timestamp),

                Mstr = element(
                    Month, {\"Jan\", \"Feb\", \"Mar\", \"Apr\", \"May\", \"Jun\", \"Jul\", \"Aug\", \"Sep\", \"Oct\", \"Nov\", \"Dec\"}
                ),

            Meridiem =
                case Hour < 12 of
                    true -> \"AM\";
                    false -> \"PM\"
                end,

            MeridiemHour =
                case Hour > 12 of
                    true -> Hour - 12;
                    false -> Hour
                end,

                Formatted =
                    case Unit of
                        millisecond ->
                            Milli = Micro div 1000,

                            io_lib:format(\"~2w ~s ~4w ~2w:~2..0w:~2..0w.~3..0w ~s\", [
                                Day, Mstr, Year, MeridiemHour, Minute, Second, Milli, Meridiem
                            ]);
                        _ ->
                            io_lib:format(\"~2w ~s ~4w ~2w:~2..0w:~2..0w ~s\", [
                                Day, Mstr, Year, MeridiemHour, Minute, Second, Meridiem
                            ])
                    end,

                erlang:iolist_to_binary(Formatted).
          ",
        ),
      ),
      example([component(clock, ClockProps(label: None, time_unit: None))]),
      p([], [
        text(
          "In this example, we have a clock component that uses an effect hook to start a timer and update the time
          every second. The effect hook is defined with a dependency on the ",
        ),
        code_text([], "time"),
        text(" and "),
        code_text([], "time_unit"),
        text(
          " properties. This means that the effect will run whenever these properties change. The effect hook
          returns a cleanup function that cancels the timer. This cleanup function is called when the component is
          unmounted or when the effect hook is re-run. This is a great way to ensure that resources are cleaned up
          when they are no longer needed.",
        ),
      ]),
      p([], [
        text(
          "This example also prints a message to the console when the component is mounted using an effect hook with
          an empty list of dependencies. This effect will only run once when the component is first mounted. ",
        ),
      ]),
    ]),
  )
}
