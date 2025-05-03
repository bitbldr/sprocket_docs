import gleam/erlang
import gleam/io
import gleam/option.{type Option, None, Some}
import sprocket.{type Context, render}
import sprocket/hooks.{type Dispatcher, dep, effect, reducer}
import sprocket/html/elements.{fragment, span, text}
import sprocket/internal/utils/timer.{interval}

type ErlangTimestamp =
  #(Int, Int, Int)

type Model {
  Model(time: ErlangTimestamp, timezone: String)
}

type Msg {
  UpdateTime(ErlangTimestamp)
}

fn init() {
  fn(_dispatch) { Model(time: erlang.erlang_timestamp(), timezone: "UTC") }
}

fn update(model: Model, msg: Msg, _dispatch: Dispatcher(Msg)) -> Model {
  case msg {
    UpdateTime(time) -> {
      Model(..model, time: time)
    }
  }
}

pub type ClockProps {
  ClockProps(label: Option(String), time_unit: Option(erlang.TimeUnit))
}

pub fn clock(ctx: Context, props: ClockProps) {
  let ClockProps(label, time_unit) = props

  // Define a reducer to handle events and update the state
  use ctx, Model(time: time, ..), dispatch <- reducer(ctx, init(), update)

  // Example effect with an empty list of dependencies, runs once on mount
  use ctx <- effect(
    ctx,
    fn() {
      io.println("Clock component mounted!")
      None
    },
    [],
  )

  let time_unit =
    time_unit
    |> option.unwrap(erlang.Second)

  // Example effect that has a cleanup function and runs whenever `time_unit` changes
  use ctx <- effect(
    ctx,
    fn() {
      let interval_duration = case time_unit {
        erlang.Millisecond -> 1
        _ -> 1000
      }
      let update_time = fn() { dispatch(UpdateTime(erlang.erlang_timestamp())) }
      let cancel = interval(interval_duration, update_time)
      Some(fn() { cancel() })
    },
    [dep(time_unit)],
  )

  let current_time = format_utc_timestamp(time, time_unit)

  render(ctx, case label {
    Some(label) ->
      fragment([span([], [text(label)]), span([], [text(current_time)])])
    None -> fragment([text(current_time)])
  })
}

@external(erlang, "print_time", "format_utc_timestamp")
pub fn format_utc_timestamp(
  time: ErlangTimestamp,
  unit: erlang.TimeUnit,
) -> String
