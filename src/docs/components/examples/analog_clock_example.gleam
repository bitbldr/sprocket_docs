import docs/components/analog_clock.{
  type AnalogClockProps, AnalogClockProps, analog_clock,
}
import docs/components/common.{example}
import gleam/dict.{type Dict}
import gleam/option.{type Option}
import sprocket/component.{type Context, component, render}

pub fn props_from(_attrs: Option(Dict(String, String))) {
  AnalogClockProps
}

pub fn analog_clock_example(ctx: Context, props: AnalogClockProps) {
  render(ctx, example([component(analog_clock, props)]))
}
