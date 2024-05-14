import gleam/io
import gleam/string
import gleam/option.{type Option, None, Some}
import gleam/list
import gleam/int
import gleam/dict.{type Dict}
import pears.{type Parser, Parsed, parse, parse_string}
import pears/chars.{
  type Char, char, digit, string, whitespace, whitespace0, whitespace1,
}
import pears/combinators.{
  any, between, choice, eof, lazy, left, many1, map, maybe, none_of, one_of,
  pair, right, seq, to,
}

pub type Inline {
  Text(String)
}

type BlockAttributes =
  Dict(String, String)

pub type Block {
  Paragraph(attributes: BlockAttributes, List(Inline))
  Heading(attributes: BlockAttributes, level: Int, content: List(Inline))
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
    Ok(Parsed(_, blocks)) -> {
      io.debug(blocks)
      document_to_html(Document(blocks, dict.new()), render_component_html)
    }
    Error(_) -> ""
  }
}

fn djot_parser() -> Parser(Char, List(Block)) {
  block_parser()
  |> many1()
  |> between(whitespace0(), eof())
}

fn block_parser() -> Parser(Char, Block) {
  choice([heading(), paragraph()])
}

fn inspect(in, label) -> Parser(Char, _) {
  left(in, map(any(), fn(c) { io.debug(#(label <> ": ", c)) }))
}

fn heading() -> Parser(Char, Block) {
  maybe(block_attributes())
  |> pair(heading_level())
  |> pair(heading_chars())
  |> map(fn(p) {
    let #(#(maybe_attrs, level), heading_chars) = p

    let assert Ok(Parsed(_, inlines)) = parse(heading_chars, inline_parser())

    let id = slugify(inlines)

    let attrs =
      maybe_attrs
      |> option.unwrap(dict.new())
      |> dict.insert("id", id)

    Heading(attrs, level, inlines)
  })
}

fn heading_level() -> Parser(Char, Int) {
  string("#")
  |> many1()
  |> left(whitespace())
  |> map(fn(hashtags) { list.length(hashtags) })
}

fn heading_chars() -> Parser(Char, List(Char)) {
  none_of(["\n"])
  |> many1()
  |> between(whitespace0(), heading_end())
}

fn heading_end() -> Parser(Char, Nil) {
  choice([newline(), eof()])
}

fn double_newline() -> Parser(Char, Nil) {
  seq([symbol("\n"), symbol("\n")])
  |> map(fn(_) { Nil })
}

fn slugify(inlines: List(Inline)) -> String {
  inlines
  |> list.map(fn(inline) {
    case inline {
      Text(text) -> text
    }
  })
  |> string.concat
  |> string.replace(" ", "-")
}

fn paragraph() -> Parser(Char, Block) {
  maybe(block_attributes())
  |> pair(inline_chars())
  |> map(fn(p: #(Option(Dict(String, String)), List(Char))) {
    let assert Ok(Parsed(_, inlines)) = parse(p.1, inline_parser())

    case p {
      #(Some(attributes), _) -> Paragraph(attributes, inlines)
      #(None, _) -> Paragraph(dict.new(), inlines)
    }
  })
  |> between(whitespace0(), paragraph_end())
}

fn paragraph_end() -> Parser(Char, Nil) {
  choice([
    map(symbol("\n\n"), fn(_) { Nil }),
    symbol("\n")
    |> right(eof()),
    eof(),
  ])
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

fn inline_chars() -> Parser(Char, List(Char)) {
  any()
  |> many1()
  |> between(whitespace0(), end_of_line())
}

fn end_of_line() -> Parser(Char, Nil) {
  choice([newline(), eof()])
}

fn newline() -> Parser(Char, Nil) {
  symbol("\n")
  |> map(fn(_) { Nil })
}

fn inline_parser() -> Parser(Char, List(Inline)) {
  choice([text()])
  |> many1()
  |> between(whitespace0(), choice([newline(), eof()]))
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
  |> string.join("")
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
    Heading(attributes, level, inlines) -> {
      let id =
        dict.get(attributes, "id")
        |> option.from_result()

      let attrs =
        attributes
        |> dict.delete("id")
        |> dict.to_list()
        |> list.fold("", fn(acc, attr) {
          let #(key, value) = attr
          string.concat([" ", key, "=\"", value, "\"", acc])
        })

      [
        "<h",
        int.to_string(level),
        attrs,
        ">",
        inlines
        |> list.fold("", fn(acc, inline) { acc <> inline_to_html(inline) }),
        "</h",
        int.to_string(level),
        ">",
        "\n",
      ]
      |> string.join("")
      |> wrap_in_section(id)
    }
  }
}

fn wrap_in_section(content: String, id: Option(String)) -> String {
  case id {
    Some(id) ->
      string.concat([
        "<section id=\"",
        id,
        "\">",
        "\n",
        content,
        "</section>",
        "\n",
      ])
    None -> string.concat(["<section>", content, "</section>", "\n"])
  }
}

fn inline_to_html(inline: Inline) -> String {
  case inline {
    Text(text) -> text
  }
}
