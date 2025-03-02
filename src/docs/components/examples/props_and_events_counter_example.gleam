import docs/components/common.{example}
import docs/components/events_counter.{CounterProps, counter}
import gleam/dict.{type Dict}
import gleam/option.{type Option, None, Some}
import sprocket/component.{component, render}
import sprocket/context.{type Context}

pub fn props_from(attrs: Option(Dict(String, String))) {
  case attrs {
    None -> PropsAndEventsCounterExampleProps
    Some(_attrs) -> PropsAndEventsCounterExampleProps
  }
}

pub type PropsAndEventsCounterExampleProps {
  PropsAndEventsCounterExampleProps
}

pub fn props_and_events_counter_example(
  ctx: Context,
  _props: PropsAndEventsCounterExampleProps,
) {
  render(
    ctx,
    example([component(counter, CounterProps(initial: 0, enable_reset: False))]),
  )
}
