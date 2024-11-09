import docs/components/common.{example}
import docs/components/products.{type Product, Product, product_card}
import gleam/dict
import gleam/float
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/result
import sprocket/component.{render}
import sprocket/context.{type Context}

pub fn props_from(attrs: Option(List(#(String, String)))) {
  case attrs {
    None -> ProductCardExampleProps(Product(0, "", "", "", "", 0.0))
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

      ProductCardExampleProps(Product(
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

pub type ProductCardExampleProps {
  ProductCardExampleProps(product: Product)
}

pub fn product_card_example(ctx: Context, props: ProductCardExampleProps) {
  let ProductCardExampleProps(product) = props

  render(ctx, example([product_card(product, None)]))
}
