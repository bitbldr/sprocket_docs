import sprocket/cassette.{type Cassette}

pub type AppContext {
  AppContext(secret_key_base: String, ca: Cassette)
}
