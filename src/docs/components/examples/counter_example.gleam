import docs/components/common.{example}
import docs/components/events_counter.{CounterProps, counter}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import sprocket.{type Context, component, render}

pub fn props_from(attrs: Option(Dynamic)) -> CounterExampleProps {
  let default = CounterExampleProps(initial: 0, enable_reset: False)

  case attrs {
    None -> default
    Some(attrs) -> {
      decode.run(attrs, {
        use initial <- decode.optional_field(
          "initial",
          0,
          decode.string
            |> decode.map(int.parse)
            |> decode.map(result.unwrap(_, 0)),
        )

        use enable_reset <- decode.optional_field(
          "enable_reset",
          False,
          decode.string
            |> decode.map(fn(enable_reset) {
              case string.lowercase(enable_reset) {
                "true" -> True
                _ -> False
              }
            }),
        )

        decode.success(CounterExampleProps(
          initial: initial,
          enable_reset: enable_reset,
        ))
      })
      |> result.unwrap(default)
    }
  }
}

pub type CounterExampleProps {
  CounterExampleProps(initial: Int, enable_reset: Bool)
}

pub fn counter_example(ctx: Context, props: CounterExampleProps) {
  let CounterExampleProps(initial, enable_reset) = props

  render(
    ctx,
    example([
      component(
        counter,
        CounterProps(initial: initial, enable_reset: enable_reset),
      ),
    ]),
  )
}
