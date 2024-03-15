import gleam/option.{type Option, None, Some}
import gleam/bytes_builder.{type BytesBuilder}
import gleam/http/response.{type Response}
import gleam/crypto
import gleam/string
import gleam/bit_array
import mist.{type ResponseData}

/// Maybe return Some element if the condition is true
/// otherwise return None
pub fn maybe(condition: Bool, element: a) -> Option(a) {
  case condition {
    True -> Some(element)
    False -> None
  }
}

pub fn mist_response(response: Response(BytesBuilder)) -> Response(ResponseData) {
  response.new(response.status)
  |> response.set_body(mist.Bytes(response.body))
}

/// Generate a random string of the given length
pub fn random_string(length: Int) -> String {
  crypto.strong_random_bytes(length)
  |> bit_array.base64_url_encode(False)
  |> string.slice(0, length)
}

@external(erlang, "sprocket_docs_ffi", "priv_directory")
pub fn priv_directory() -> String
