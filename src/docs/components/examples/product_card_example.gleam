import docs/components/common.{example}
import docs/components/products.{type Product, Product, product_card}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/result
import sprocket/component.{type Context, render}

pub fn props_from(attrs: Option(Dynamic)) -> ProductCardExampleProps {
  let default = ProductCardExampleProps(Product(0, "", "", "", "", 0.0))

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
          ProductCardExampleProps(Product(
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

pub type ProductCardExampleProps {
  ProductCardExampleProps(product: Product)
}

pub fn product_card_example(ctx: Context, props: ProductCardExampleProps) {
  let ProductCardExampleProps(product) = props

  render(ctx, example([product_card(product, None)]))
}
