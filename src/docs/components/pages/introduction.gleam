import sprocket/context.{type Context}
import sprocket/component.{render}
import sprocket/html/elements.{article, div, h1, h2, li, p, span, text, ul}
import sprocket/html/attributes.{class}
import docs/components/common.{alert}

pub type IntroductionPageProps {
  IntroductionPageProps
}

pub fn introduction_page(ctx: Context, _props: IntroductionPageProps) {
  render(
    ctx,
    [
      article(
        [],
        [
          h1([], [text("Introduction")]),
          p(
            [],
            [
              text(
                "
                    Welcome to the official documentation for Sprocket, a real-time server-side component library for Gleam! In this guide, we'll
                    cover the core concepts of Sprocket, but some prerequisite knowledge of Gleam is recommended. Gleam is a type-safe functional language designed
                    to harness the power of the Erlang Beam virtual machine. Whether you are a Gleam enthusiast or new to this exciting language,
                    this documentation will serve as your roadmap to building highly scalable, robust, and efficient server-side component views for your web application.
                    ",
              ),
            ],
          ),
          p(
            [class("italic")],
            [
              span([class("font-bold")], [text("Fun fact: ")]),
              text(
                "Sprocket is named after the humble bicycle gear that enables the wheels to spin effortlessly! Also, this documentation is completely powered by it!",
              ),
            ],
          ),
          alert(
            common.Warning,
            [
              div([class("mr-2")], [span([class("text-xl")], [text("🚧")])]),
              div(
                [class("flex-grow-1")],
                [
                  span([class("font-bold")], [text("Important Note: ")]),
                  text(
                    "Sprocket is under heavy development and this documentation is a work in progress! Please proceed with caution as things are likely to change.",
                  ),
                ],
              ),
              div([class("ml-2")], [span([class("text-xl")], [text("🚧")])]),
            ],
          ),
          h2([], [text("Why Another Component Library?")]),
          p(
            [],
            [
              text(
                "
                  Sprocket is designed around a collection of proven functional patterns that empower developers to build scalable applications with ease.
                  Embracing the strengths of the Erlang Beam virtual machine's concurrency and fault-tolerance capabilities enables developers to build
                  highly scalable and fault-tolerant applications that are easy to reason about and maintain.
                ",
              ),
            ],
          ),
          p(
            [],
            [
              text(
                "
                  The main goal of this library is to bridge the gap between existing functional component libraries, type-safety, and real-time server rendered
                  views so that developers can quickly construct applications without compromising on type guarantees. By leveraging the Erlang Beam VM,
                  Sprocket is built on a solid foundation that enables performant, scalable, and fault-tolerant applications.
                ",
              ),
            ],
          ),
          h2([], [text("Key Features")]),
          p(
            [],
            [
              ul(
                [],
                [
                  li(
                    [],
                    [
                      span(
                        [class("font-bold")],
                        [text("Real-time Components: ")],
                      ),
                      text(
                        "Build scalable real-time server-rendered applications by designing modular and reusable components with Sprocket's declarative approach.",
                      ),
                    ],
                  ),
                  li(
                    [],
                    [
                      span([class("font-bold")], [text("Type-Safety: ")]),
                      text(
                        "Gleam's static typing guarantees that your code is free of runtime errors while making it easier to reason about complex systems and
                        build maintainable codebases.",
                      ),
                    ],
                  ),
                  li(
                    [],
                    [
                      span([class("font-bold")], [text("Concurrency: ")]),
                      text(
                        "Sprocket harnesses the power of the Erlang Beam VM, providing lightweight processes and easy-to-use abstractions for
                      concurrent programming.",
                      ),
                    ],
                  ),
                  li(
                    [],
                    [
                      span([class("font-bold")], [text("Fault-Tolerance: ")]),
                      text(
                        "Battle-tested fault-tolerance mechanisms ensure that your applications are resilient even under adverse conditions.",
                      ),
                    ],
                  ),
                  li(
                    [],
                    [
                      span([class("font-bold")], [text("Interoperability: ")]),
                      text(
                        "Seamlessly plug-in to Erlang/Elixir's exisitng libraries with Gleam's first class FFI.",
                      ),
                    ],
                  ),
                  li(
                    [],
                    [
                      span([class("font-bold")], [text("Scalability: ")]),
                      text(
                        "Easily scale your application thanks to the Erlang Beam VM's distributed nature.",
                      ),
                    ],
                  ),
                  li(
                    [],
                    [
                      span([class("font-bold")], [text("Open Source: ")]),
                      text(
                        "Sprocket is completely open-source and free to use. Contributions are welcome and encouraged!",
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          h2([], [text("Ready to get started?")]),
          p(
            [],
            [
              text(
                "In the next section, we'll cover prerequisites and getting your Sprocket application up and running.",
              ),
            ],
          ),
        ],
      ),
    ],
  )
}
