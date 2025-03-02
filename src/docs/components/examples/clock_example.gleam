import docs/components/clock.{type ClockProps, ClockProps, clock}
import docs/components/common.{example}
import gleam/dict.{type Dict}
import gleam/erlang
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import sprocket/component.{component, render}
import sprocket/context.{type Context}

pub fn props_from(attrs: Option(Dict(String, String))) {
  case attrs {
    None -> ClockProps(label: None, time_unit: None)
    Some(attrs) -> {
      let time_unit =
        attrs
        |> dict.get("time_unit")
        |> result.map(fn(time_unit) {
          case string.lowercase(time_unit) {
            "millisecond" -> erlang.Millisecond
            _ -> erlang.Second
          }
        })
        |> option.from_result

      let label =
        attrs
        |> dict.get("label")
        |> option.from_result

      ClockProps(label: label, time_unit: time_unit)
    }
  }
}

pub fn clock_example(ctx: Context, props: ClockProps) {
  render(ctx, example([component(clock, props)]))
}
