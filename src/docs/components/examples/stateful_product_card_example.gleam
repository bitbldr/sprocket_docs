import docs/components/common.{example}
import docs/components/products.{type Product, Product, product_card}
import docs/components/toggle_button.{ToggleButtonProps, toggle_button}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/result
import sprocket.{type Context, component, render}
import sprocket/html/attributes.{class}
import sprocket/html/elements.{div, i, span, text}

pub type StatefulProductCardExampleProps {
  StatefulProductCardExampleProps(product: Product)
}

pub fn stateful_product_card_example(
  ctx: Context,
  props: StatefulProductCardExampleProps,
) {
  let StatefulProductCardExampleProps(product) = props

  render(
    ctx,
    example([
      div([class("flex flex-col")], [
        product_card(
          product,
          Some([
            component(
              toggle_button,
              ToggleButtonProps(render_label: fn(toggle) {
                case toggle {
                  True ->
                    span([], [
                      i([class("fa-solid fa-check mr-2")], []),
                      text("Added to Cart!"),
                    ])
                  False ->
                    span([], [
                      i([class("fa-solid fa-cart-shopping mr-2")], []),
                      text("Add to Cart"),
                    ])
                }
              }),
            ),
          ]),
        ),
      ]),
    ]),
  )
}

pub fn props_from(attrs: Option(Dynamic)) -> StatefulProductCardExampleProps {
  let default = StatefulProductCardExampleProps(Product(0, "", "", "", "", 0.0))

  case attrs {
    None -> default
    Some(attrs) -> {
      decode.run(attrs, {
        use id <- decode.optional_field(
          "id",
          0,
          decode.string
            |> decode.map(int.parse)
            |> decode.map(result.unwrap(_, 0)),
        )

        use name <- decode.optional_field("name", "", decode.string)

        use description <- decode.optional_field(
          "description",
          "",
          decode.string,
        )

        use img_url <- decode.optional_field("img_url", "", decode.string)

        use qty <- decode.optional_field("qty", "", decode.string)

        use price <- decode.optional_field(
          "price",
          0.0,
          decode.string
            |> decode.map(float.parse)
            |> decode.map(result.unwrap(_, 0.0)),
        )

        decode.success(
          StatefulProductCardExampleProps(Product(
            id: id,
            name: name,
            description: description,
            img_url: img_url,
            qty: qty,
            price: price,
          )),
        )
      })
      |> result.unwrap(default)
    }
  }
}
