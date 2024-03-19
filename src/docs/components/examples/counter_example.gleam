import gleam/int
import gleam/result
import gleam/string
import gleam/dict
import sprocket/context.{type Context}
import sprocket/component.{component, render}
import docs/components/common.{example}
import docs/components/events_counter.{CounterProps, counter}

pub fn props_for_counter_example(props: List(#(String, String))) {
  let props =
    props
    |> dict.from_list()

  let enable_reset =
    props
    |> dict.get("enable_reset")
    |> result.map(fn(enable_reset) {
      case string.lowercase(enable_reset) {
        "true" -> True
        _ -> False
      }
    })
    |> result.unwrap(False)

  let initial =
    props
    |> dict.get("initial")
    |> result.try(int.parse)
    |> result.unwrap(0)

  CounterExampleProps(initial: initial, enable_reset: enable_reset)
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
