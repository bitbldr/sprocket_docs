import docs/components/products.{type Product, Product, ProductProps, product}
import gleam/int
import gleam/list
import sprocket.{type Context, component, render}
import sprocket/hooks.{state}
import sprocket/html/attributes.{class, role}
import sprocket/html/elements.{button, div, keyed, li, text, ul}
import sprocket/html/events

pub type ProductListProps {
  ProductListProps(products: List(Product))
}

pub fn product_list(ctx: Context, props: ProductListProps) {
  let ProductListProps(products: products) = props

  // Create a state variable to keep track of hidden products
  use ctx, hidden, set_hidden <- state(ctx, [])

  let hide = fn(id) { set_hidden([id, ..hidden]) }
  let reset = fn(_) { set_hidden([]) }

  // Map over the products and render a product component for each, filtering out hidden products
  let products =
    products
    |> list.filter_map(fn(p) {
      case list.contains(hidden, p.id) {
        True -> Error(Nil)
        False ->
          Ok(keyed(
            int.to_string(p.id),
            li([class("py-3 mr-4")], [
              component(
                product,
                ProductProps(product: p, on_hide: fn(_) { hide(p.id) }),
              ),
            ]),
          ))
      }
    })

  render(
    ctx,
    div([], [
      ul([role("list"), class("flex flex-col")], products),
      ..case list.is_empty(hidden) {
        True -> []
        False -> [
          button(
            [
              class(
                "mt-5 text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800",
              ),
              events.on_click(reset),
            ],
            [text("Show Hidden (" <> int.to_string(list.length(hidden)) <> ")")],
          ),
        ]
      }
    ]),
  )
}
