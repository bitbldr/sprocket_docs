import gleam/bytes_builder.{type BytesBuilder}
import gleam/string
import gleam/option.{None, Some}
import gleam/bit_array
import gleam/result
import gleam/erlang
import gleam/http.{Get}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type Connection, type ResponseData}
import gleam/http/service.{type Service}
import docs/log_requests
import docs/static
import docs/utils/csrf
import docs/utils/logger
import docs/utils/common.{mist_response}
import docs/app_context.{type AppContext}
import docs/page_route
import docs/controllers/standalone.{standalone}
import docs/layouts/page_layout.{page_layout}
import docs/components/counter.{CounterProps, counter}
import docs/components/page.{PageProps, page}
import mist_sprocket.{component, view}

pub fn router(app: AppContext) {
  fn(request: Request(Connection)) -> Response(ResponseData) {
    use <- rescue_crashes()

    case request.method, request.path_segments(request) {
      Get, ["standalone"] -> standalone(request, app)
      Get, ["counter", _] ->
        component(
          request,
          counter,
          CounterProps(initial: Some(100)),
          app.validate_csrf,
          None,
        )

      Get, _ ->
        view(
          request,
          page_layout("Sprocket Docs", csrf.generate(app.secret_key_base)),
          page,
          PageProps(route: page_route.from_string(request.path)),
          app.validate_csrf,
          None,
        )

      _, _ ->
        not_found()
        |> response.map(bytes_builder.from_string)
        |> mist_response()
    }
  }
}

pub fn stack(ctx: AppContext) -> Service(Connection, ResponseData) {
  router(ctx)
  // |> string_body_middleware
  |> log_requests.middleware
  |> static.middleware()
  |> service.prepend_response_header("made-with", "Gleam")
}

pub fn string_body_middleware(
  service: Service(String, String),
) -> Service(BitArray, BytesBuilder) {
  fn(request: Request(BitArray)) {
    case bit_array.to_string(request.body) {
      Ok(body) -> service(request.set_body(request, body))
      Error(_) -> bad_request()
    }
    |> response.map(bytes_builder.from_string)
  }
}

pub fn method_not_allowed() -> Response(String) {
  response.new(405)
  |> response.set_body("Method not allowed")
  |> response.prepend_header("content-type", "text/plain")
}

pub fn not_found() -> Response(String) {
  response.new(404)
  |> response.set_body("Page not found")
  |> response.prepend_header("content-type", "text/plain")
}

pub fn bad_request() -> Response(String) {
  response.new(400)
  |> response.set_body("Bad request. Please try again")
  |> response.prepend_header("content-type", "text/plain")
}

pub fn internal_server_error() -> Response(String) {
  response.new(500)
  |> response.set_body("Internal Server Error")
  |> response.prepend_header("content-type", "text/plain")
}

pub fn http_service(
  req: Request(Connection),
  service: Service(BitArray, BytesBuilder),
) -> Response(ResponseData) {
  req
  |> mist.read_body(1024 * 1024 * 10)
  |> result.map(fn(http_req: Request(BitArray)) {
    http_req
    |> service()
    |> mist_response()
  })
  |> result.unwrap(
    response.new(500)
    |> response.set_body(mist.Bytes(bytes_builder.new())),
  )
}

pub fn rescue_crashes(
  handler: fn() -> Response(ResponseData),
) -> Response(ResponseData) {
  case erlang.rescue(handler) {
    Ok(response) -> response
    Error(error) -> {
      logger.error(string.inspect(error))

      internal_server_error()
      |> response.map(bytes_builder.from_string)
      |> mist_response()
    }
  }
}
