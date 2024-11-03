import docs/utils/logger
import gleam/dict
import gleam/io
import gleam/option.{None, Some}
import sprocket/component.{render}
import sprocket/context.{type Context}
import sprocket/hooks.{handler, state}
import sprocket/html/attributes.{class, input_type, name}
import sprocket/html/elements.{
  button, div, form, fragment, input, keyed, span, text,
}
import sprocket/html/events

pub type ExampleFormProps {
  ExampleFormProps
}

pub fn example_form(ctx: Context, _props: ExampleFormProps) {
  use ctx, validation_error, set_validation_error <- state(ctx, None)

  use ctx, handle_form_submit <- handler(ctx, fn(e) {
    case events.decode_form_data(e) {
      Ok(data) -> {
        io.debug(data)
        logger.info("Form submitted")
      }
      Error(_) -> logger.error("Error decoding form submit")
    }
  })

  use ctx, validate <- handler(ctx, fn(e) {
    case events.decode_form_data(e) {
      Ok(data) -> {
        case dict.get(data, "name") {
          Ok("") -> {
            set_validation_error(Some("Name cannot be empty"))
          }
          Ok("admin") -> {
            set_validation_error(Some("Name cannot be admin"))
          }
          Ok(_) -> {
            set_validation_error(None)
          }
          Error(Nil) -> logger.error("Name not found in form data")
        }
      }
      Error(_) -> logger.error("Error decoding form validation")
    }
  })

  render(
    ctx,
    form([events.on_change(validate), events.on_submit(handle_form_submit)], [
      div([class("flex flex-col m-4")], [
        span([class("text-2xl")], [text("Example form")]),
        keyed("validation_error", case validation_error {
          Some(error) -> div([class("text-red-400")], [text(error)])
          None -> div([], [])
        }),
        input([
          input_type("text"),
          name("name"),
          class("p-2 border border-gray-300 rounded"),
        ]),
        button([class("p-2 mt-2 bg-blue-500 text-white rounded")], [
          text("Submit"),
        ]),
      ]),
    ]),
  )
}
