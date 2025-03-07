import docs/app_context.{AppContext}
import docs/page_server
import docs/router
import docs/utils/csrf
import docs/utils/logger
import envoy
import gleam/erlang/process
import gleam/int
import gleam/result
import mist

pub fn main() {
  logger.configure_backend(logger.Info)

  let secret_key_base = load_secret_key_base()
  let port = load_port()

  let assert Ok(page_server) = page_server.start()

  let assert Ok(_) =
    router.stack(AppContext(
      secret_key_base,
      csrf.validate(_, secret_key_base),
      page_server,
    ))
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(port)
    |> mist.start_http

  process.sleep_forever()
}

fn load_port() -> Int {
  envoy.get("PORT")
  |> result.then(int.parse)
  |> result.unwrap(3000)
}

fn load_secret_key_base() -> String {
  envoy.get("SECRET_KEY_BASE")
  |> result.unwrap("change_me")
}
