import gleam/option.{None, Some}
import sprocket/context.{type Context}
import sprocket/component.{component, render}
import sprocket/html/elements.{article, h1, p, text}
import docs/components/clock.{ClockProps, clock}

pub type EffectsPageProps {
  EffectsPageProps
}

pub fn effects_page(ctx: Context, _props: EffectsPageProps) {
  render(
    ctx,
    [
      article(
        [],
        [
          h1([], [text("Effects")]),
          p([], [text("COMING SOON")]),
          component(
            clock,
            ClockProps(label: Some("The current time is: "), time_unit: None),
          ),
        ],
      ),
    ],
  )
}
