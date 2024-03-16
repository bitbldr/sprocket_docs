import gleam/result
import gleam/string
import gleam/dict.{type Dict}
import sprocket/context.{type Context}
import sprocket/component.{component, render}
import docs/components/common.{example}
import docs/components/events_counter.{CounterProps, counter}

pub fn props_for_counter_example(props: Dict(String, String)) {
  let enable_reset =
    dict.get(props, "enable_reset")
    |> result.map(fn(enable_reset) {
      case string.lowercase(enable_reset) {
        "true" -> True
        _ -> False
      }
    })
    |> result.unwrap(False)

  CounterExampleProps(enable_reset: enable_reset)
}

pub type CounterExampleProps {
  CounterExampleProps(enable_reset: Bool)
}

pub fn counter_example(ctx: Context, props: CounterExampleProps) {
  let CounterExampleProps(enable_reset) = props

  render(
    ctx,
    example([component(counter, CounterProps(enable_reset: enable_reset))]),
  )
}
