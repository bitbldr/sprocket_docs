// import gleam/dynamic.{Dynamic}

pub type DarkMode {
  Auto
  Light
  Dark
}

pub type Theme {
  Theme(mode: DarkMode, set_mode: fn(DarkMode) -> Nil)
}
// pub fn theme_provider() -> Theme {
//   Theme(mode: Auto)
// }

// fn create_provider(value: v) -> v {
//   value
// }

// pub const 
