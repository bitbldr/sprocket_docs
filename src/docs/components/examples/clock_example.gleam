import docs/components/clock.{type ClockProps, ClockProps, clock}
import docs/components/common.{example}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/erlang
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import sprocket/component.{type Context, component, render}

pub fn clock_example(ctx: Context, props: ClockProps) {
  render(ctx, example([component(clock, props)]))
}

pub fn props_from(attrs: Option(Dynamic)) -> ClockProps {
  let default = ClockProps(label: None, time_unit: None)

  case attrs {
    None -> default
    Some(attrs) -> {
      decode.run(attrs, {
        use label <- decode.optional_field(
          "label",
          None,
          decode.optional(decode.string),
        )

        use time_unit <- decode.optional_field(
          "time_unit",
          None,
          decode.optional(
            decode.string
            |> decode.map(fn(time_unit) {
              case string.lowercase(time_unit) {
                "millisecond" -> erlang.Millisecond
                _ -> erlang.Second
              }
            }),
          ),
        )

        decode.success(ClockProps(label: label, time_unit: time_unit))
      })
      |> result.unwrap(default)
    }
  }
}
