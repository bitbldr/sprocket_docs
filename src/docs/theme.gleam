pub type DarkMode {
  Auto
  Light
  Dark
}

pub type Theme {
  Theme(mode: DarkMode, set_mode: fn(DarkMode) -> Nil)
}

pub const provider_key = "theme"
