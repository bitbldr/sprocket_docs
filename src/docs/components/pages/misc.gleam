import gleam/option.{type Option, None, Some}
import gleam/erlang
import sprocket/context.{type Context}
import sprocket/component.{component, render}
import sprocket/html/elements.{
  a_text, article, button_text, dangerous_raw_html, div, h1, h2, p, p_text, text,
}
import sprocket/html/attributes.{class, classes, href, on_click}
import sprocket/hooks.{handler, reducer}
import docs/components/clock.{ClockProps, clock}
import docs/components/analog_clock.{AnalogClockProps, analog_clock}
import docs/components/counter.{CounterProps, counter}
import docs/components/hello_button.{HelloButtonProps, hello_button}

type Msg {
  NoOp
  SetTimeUnit(erlang.TimeUnit)
}

type Model {
  Model(time_unit: erlang.TimeUnit)
}

fn update(state: Model, msg: Msg) -> Model {
  case msg {
    NoOp -> state
    SetTimeUnit(time_unit) -> Model(time_unit)
  }
}

fn initial() -> Model {
  Model(time_unit: erlang.Second)
}

pub type MiscPageProps {
  MiscPageProps
}

pub fn misc_page(ctx: Context, _props: MiscPageProps) {
  use ctx, Model(time_unit), _dispatch <- reducer(ctx, initial(), update)

  render(
    ctx,
    [
      article(
        [],
        [
          h1([], [text("Miscellaneous")]),
          h2([], [text("Example Components")]),
          div(
            [],
            [
              div([class("my-2")], [component(analog_clock, AnalogClockProps)]),
              div(
                [],
                [
                  component(
                    clock,
                    ClockProps(
                      label: Some("The current time is: "),
                      time_unit: Some(time_unit),
                    ),
                  ),
                ],
              ),
              p(
                [],
                [
                  text(
                    "An html escaped & safe <span style=\"color: green\">string</span>",
                  ),
                ],
              ),
              p(
                [],
                [
                  dangerous_raw_html(
                    "A <b>raw <em>html</em></b> <span style=\"color: blue\">string</span></b>",
                  ),
                ],
              ),
              component(counter, CounterProps(initial: Some(0))),
              component(hello_button, HelloButtonProps),
            ],
          ),
          h2([], [text("Standalone Components")]),
          div(
            [],
            [
              p_text(
                [],
                "Components can be rendered as standalone into existing HTML pages.",
              ),
              p([], [a_text([href("/standalone")], "Standalone Example")]),
            ],
          ),
        ],
      ),
    ],
  )
}

type UnitToggleProps {
  UnitToggleProps(
    current: erlang.TimeUnit,
    on_select: fn(erlang.TimeUnit) -> Nil,
  )
}

fn unit_toggle(ctx: Context, props: UnitToggleProps) {
  let UnitToggleProps(current, on_select) = props

  use ctx, on_select_millisecond <- handler(
    ctx,
    fn(_) { on_select(erlang.Millisecond) },
  )

  use ctx, on_select_second <- handler(ctx, fn(_) { on_select(erlang.Second) })

  render(
    ctx,
    [
      div(
        [],
        [
          p(
            [],
            [
              button_text(
                [
                  on_click(on_select_second),
                  classes([
                    Some(
                      "p-1 px-2 border dark:border-gray-500 rounded-l bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 active:bg-gray-300 dark:active:bg-gray-600",
                    ),
                    maybe_active(current == erlang.Second),
                  ]),
                ],
                "Second",
              ),
              button_text(
                [
                  on_click(on_select_millisecond),
                  classes([
                    Some(
                      "p-1 px-2 border dark:border-gray-500 rounded-r bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 active:bg-gray-300 dark:active:bg-gray-600",
                    ),
                    maybe_active(current == erlang.Millisecond),
                  ]),
                ],
                "Millisecond",
              ),
            ],
          ),
        ],
      ),
    ],
  )
}

fn maybe_active(is_active: Bool) -> Option(String) {
  case is_active {
    True ->
      Some(
        "text-white bg-gray-500 border-gray-500 hover:bg-gray-500 dark:bg-gray-900",
      )
    False -> None
  }
}
