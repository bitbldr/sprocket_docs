import docs/components/common.{example}
import docs/components/products.{
  ProductListProps, example_coffee_products, product_list,
}
import gleam/dict.{type Dict}
import gleam/option.{type Option, None, Some}
import sprocket/component.{type Context, component, render}

pub fn props_from(attrs: Option(Dict(String, String))) {
  case attrs {
    None -> ProductListExampleProps
    Some(_attrs) -> ProductListExampleProps
  }
}

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
