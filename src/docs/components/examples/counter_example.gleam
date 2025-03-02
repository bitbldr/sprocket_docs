import docs/components/common.{example}
import docs/components/events_counter.{CounterProps, counter}
import gleam/dict.{type Dict}
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import sprocket/component.{component, render}
import sprocket/context.{type Context}

pub fn props_from(attrs: Option(Dict(String, String))) {
  case attrs {
    None -> CounterExampleProps(initial: 0, enable_reset: False)
    Some(attrs) -> {
      let enable_reset =
        attrs
        |> dict.get("enable_reset")
        |> result.map(fn(enable_reset) {
          case string.lowercase(enable_reset) {
            "true" -> True
            _ -> False
          }
        })
        |> result.unwrap(False)

      let initial =
        attrs
        |> dict.get("initial")
        |> result.try(int.parse)
        |> result.unwrap(0)

      CounterExampleProps(initial: initial, enable_reset: enable_reset)
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
