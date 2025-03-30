import docs/components/analog_clock.{
  type AnalogClockProps, AnalogClockProps, analog_clock,
}
import docs/components/common.{example}
import gleam/dynamic.{type Dynamic}
import gleam/option.{type Option}
import sprocket.{type Context, component, render}

pub fn analog_clock_example(ctx: Context, props: AnalogClockProps) {
  render(ctx, example([component(analog_clock, props)]))
}

pub fn props_from(_attrs: Option(Dynamic)) -> AnalogClockProps {
  AnalogClockProps
}
