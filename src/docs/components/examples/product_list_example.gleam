import docs/components/common.{example}
import docs/components/products.{
  ProductListProps, example_coffee_products, product_list,
}
import gleam/dynamic.{type Dynamic}
import gleam/option.{type Option, None, Some}
import sprocket.{type Context, component, render}

pub type ProductListExampleProps {
  ProductListExampleProps
}

pub fn product_list_example(ctx: Context, _props: ProductListExampleProps) {
  render(
    ctx,
    example([
      component(
        product_list,
        ProductListProps(products: example_coffee_products()),
      ),
    ]),
  )
}

pub fn props_from(attrs: Option(Dynamic)) -> ProductListExampleProps {
  case attrs {
    None -> ProductListExampleProps
    Some(_attrs) -> ProductListExampleProps
  }
}
