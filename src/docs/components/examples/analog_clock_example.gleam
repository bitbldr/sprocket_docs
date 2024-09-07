import docs/components/analog_clock.{
  type AnalogClockProps, AnalogClockProps, analog_clock,
}
import docs/components/common.{example}
import gleam/option.{type Option}
import sprocket/component.{component, render}
import sprocket/context.{type Context}

pub fn props_from(_attrs: Option(List(#(String, String)))) {
  AnalogClockProps
}

pub fn analog_clock_example(ctx: Context, props: AnalogClockProps) {
  render(ctx, example([component(analog_clock, props)]))
}
