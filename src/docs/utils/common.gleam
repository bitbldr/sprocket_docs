import gleam/bit_array
import gleam/bytes_builder.{type BytesBuilder}
import gleam/crypto
import gleam/http/response.{type Response}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/string_builder
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

fn safe_replace_char(key: String) -> String {
  case key {
    "&" -> "&amp;"
    "<" -> "&lt;"
    ">" -> "&gt;"
    "\"" -> "&quot;"
    "'" -> "&#39;"
    "/" -> "&#x2F;"
    "`" -> "&#x60;"
    "=" -> "&#x3D;"
    _ -> key
  }
}

pub fn escape_html(unsafe: String) {
  string.to_graphemes(unsafe)
  |> list.fold(string_builder.new(), fn(sb, grapheme) {
    string_builder.append(sb, safe_replace_char(grapheme))
  })
  |> string_builder.to_string
}

@external(erlang, "sprocket_docs_ffi", "priv_directory")
pub fn priv_directory() -> String
