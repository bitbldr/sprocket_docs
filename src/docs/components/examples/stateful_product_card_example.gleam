import docs/components/common.{example}
import docs/components/products.{type Product, Product, product_card}
import docs/components/toggle_button.{ToggleButtonProps, toggle_button}
import gleam/dict
import gleam/float
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/result
import sprocket/component.{component, render}
import sprocket/context.{type Context}
import sprocket/html/attributes.{class}
import sprocket/html/elements.{div, i, span, text}

pub fn props_from(attrs: Option(List(#(String, String)))) {
  case attrs {
    None -> StatefulProductCardExampleProps(Product(0, "", "", "", "", 0.0))
    Some(attrs) -> {
      let attrs =
        attrs
        |> dict.from_list()

      let id =
        attrs
        |> dict.get("id")
        |> result.try(int.parse)
        |> result.unwrap(0)

      let name =
        attrs
        |> dict.get("name")
        |> result.unwrap("")

      let description =
        attrs
        |> dict.get("description")
        |> result.unwrap("")

      let img_url =
        attrs
        |> dict.get("img_url")
        |> result.unwrap("")

      let qty =
        attrs
        |> dict.get("qty")
        |> result.unwrap("")

      let price =
        attrs
        |> dict.get("price")
        |> result.try(float.parse)
        |> result.unwrap(0.0)

      StatefulProductCardExampleProps(Product(
        id,
        name,
        description,
        img_url,
        qty,
        price,
      ))
    }
  }
}

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
