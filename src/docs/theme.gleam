import sprocket.{type Element}
import sprocket/hooks.{provide}

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
  provide(provider_key, theme, element)
}
