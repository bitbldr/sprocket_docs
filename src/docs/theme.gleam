import sprocket/context.{type Element}

pub type DarkMode {
  Auto
  Light
  Dark
}

pub type Theme {
  Theme(mode: DarkMode, set_mode: fn(DarkMode) -> Nil)
}

pub const provider_key = "theme"

pub fn provider(theme: Theme, element: Element) -> Element {
  context.provider(provider_key, theme, element)
}
