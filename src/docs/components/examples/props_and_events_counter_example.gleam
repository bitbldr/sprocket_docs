import docs/components/common.{example}
import docs/components/events_counter.{CounterProps, counter}
import gleam/dynamic.{type Dynamic}
import gleam/option.{type Option, None, Some}
import sprocket/component.{type Context, component, render}

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

pub fn props_from(attrs: Option(Dynamic)) -> PropsAndEventsCounterExampleProps {
  case attrs {
    None -> PropsAndEventsCounterExampleProps
    Some(_attrs) -> PropsAndEventsCounterExampleProps
  }
}
