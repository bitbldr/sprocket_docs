import gleam/string
import gleam/option.{type Option, None, Some}
import gleam/list
import gleam/dict.{type Dict}
import pears.{type Parser, Parsed, parse_string}
import pears/chars.{type Char, char, digit, string, whitespace0}
import pears/combinators.{
  any, between, choice, eof, lazy, left, many1, map, maybe, one_of, pair, right,
}

pub type Inline {
  Text(String)
}

pub type Block {
  Paragraph(attributes: Dict(String, String), List(Inline))
}

type References =
  Dict(String, String)

pub type Document {
  Document(content: List(Block), references: References)
}

type ComponentRenderer =
  fn(String, List(#(String, String))) -> Result(String, Nil)

pub fn to_html(djot: String, render_component_html: ComponentRenderer) -> String {
  case parse_string(djot, djot_parser()) {
    Ok(Parsed(_, blocks)) ->
      document_to_html(Document(blocks, dict.new()), render_component_html)
    Error(_) -> ""
  }
}

fn djot_parser() -> Parser(Char, List(Block)) {
  block_parser()
  |> many1()
  |> between(whitespace0(), eof())
}

fn block_parser() -> Parser(Char, Block) {
  choice([paragraph()])
}

fn paragraph() -> Parser(Char, Block) {
  let line_content = lazy(inline_parser)

  maybe(block_attributes())
  |> pair(line_content)
  |> map(fn(p: #(Option(Dict(String, String)), List(Inline))) {
    case p {
      #(Some(attributes), inlines) -> Paragraph(attributes, inlines)
      #(None, inlines) -> Paragraph(dict.new(), inlines)
    }
  })
  |> between(whitespace0(), paragraph_end())
}

fn paragraph_end() -> Parser(Char, Nil) {
  choice([map(string("\n\n"), fn(_) { Nil }), eof()])
}

/// <BlockAttributes> ::= "{" <Attribute>+ "}"
/// <Attribute> ::= <Id> | <Class> | <NativeAttribute>
/// <Id> ::= "#" <AttrValue> <AttributeEnd>
/// <Class> ::= "." <ClassValue> <AttributeEnd>
/// <NativeAttribute> ::= <AttributeName> "=" <AttributeValue> <AttributeEnd>
/// <AttributeName> ::= <AttrValue>
/// <AttributeValue> ::= <AttrValue>
/// <AttrValue> ::= <Letter> <AttrValueRest>
/// <AttrValueRest> ::= <Letter> | <Digit> | "_" | "-"
/// <AttributeEnd> ::= " " | "}"
/// 
fn block_attributes() -> Parser(Char, Dict(String, String)) {
  attribute()
  |> many1()
  |> between(string("{"), string("}"))
  |> map(fn(attrs) { dict.from_list(attrs) })
}

fn attribute() -> Parser(Char, #(String, String)) {
  choice([id(), class(), native_attribute()])
}

fn attribute_value() -> Parser(Char, String) {
  letter()
  |> pair(attr_value_rest())
  |> map(fn(p) { string.concat([p.0, p.1]) })
}

fn attr_value_rest() -> Parser(Char, String) {
  choice([letter(), digit(), char("_"), char("-")])
  |> many1()
  |> map(string.concat)
}

fn id() -> Parser(Char, #(String, String)) {
  string("#")
  |> right(attribute_value())
  |> map(fn(id) { #("id", id) })
}

fn class() -> Parser(Char, #(String, String)) {
  string(".")
  |> right(attribute_value())
  |> map(fn(class) { #("class", class) })
}

fn native_attribute() -> Parser(Char, #(String, String)) {
  attribute_name()
  |> left(symbol("="))
  |> pair(attribute_value())
}

fn attribute_name() -> Parser(Char, String) {
  attribute_value()
}

fn inline_parser() -> Parser(Char, List(Inline)) {
  choice([text()])
  |> many1()
}

fn text() -> Parser(Char, Inline) {
  any()
  |> many1()
  |> map(string.concat)
  |> map(fn(text) { Text(string.trim(text)) })
}

fn padded(parser: Parser(_, a)) {
  left(parser, whitespace0())
}

fn symbol(s: String) {
  padded(string(s))
}

fn letter() {
  one_of([
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o",
    "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D",
    "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",
    "T", "U", "V", "W", "X", "Y", "Z",
  ])
}

fn document_to_html(
  document: Document,
  render_component_html: ComponentRenderer,
) -> String {
  document.content
  |> list.map(fn(block) { block_to_html(block, render_component_html) })
  |> string.join("\n")
}

fn block_to_html(
  block: Block,
  _render_component_html: ComponentRenderer,
) -> String {
  case block {
    Paragraph(attributes, inlines) -> {
      let attrs =
        attributes
        |> dict.to_list()
        |> list.fold("", fn(acc, attr) {
          let #(key, value) = attr
          string.concat([" ", key, "=\"", value, "\"", acc])
        })

      [
        "<p",
        attrs,
        ">",
        inlines
        |> list.fold("", fn(acc, inline) { acc <> inline_to_html(inline) }),
        "</p>",
        "\n",
      ]
      |> string.join("")
    }
  }
}

fn inline_to_html(inline: Inline) -> String {
  case inline {
    Text(text) -> text
  }
}
