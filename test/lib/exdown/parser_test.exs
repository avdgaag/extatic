defmodule Extatic.Exdown.ParserTest do
  use ExUnit.Case, async: true

  alias Extatic.Exdown.Parser
  doctest Parser

  def parse(input) do
    with {:ok, output} <- Parser.parse(input) do
      output
    end
  end

  def fixture(filename) do
    File.read!(Path.join(["test", "fixtures", filename]))
  end

  test "parses a paragraph of text" do
    assert {[{:p, ["example text"], []}], []} == parse("example text\n")
  end

  test "parses a paragraph of text including special characters" do
    assert {[{:p, ["example text: , * _ ` <> ] [."], []}], []} ==
      parse("example text: , * _ ` <> ] [.\n")
  end

  test "parses multiple paragraphs of text" do
    output = {[{:p, ["example text"], []},
               {:p, ["another paragraph 1"], []},
               {:p, ["another paragraph 2"], []}], []}
    assert output == parse("example text\n\nanother paragraph 1\n\nanother paragraph 2\n")
  end

  test "parses h1" do
    assert {[{:h1, ["Heading 1"], []}], []} == parse("Heading 1\n===\n")
  end

  test "parses h2" do
    assert {[{:h2, ["Heading 2"], []}], []} == parse("\nHeading 2\n---\n")
  end

  test "parses paragraph and h2" do
    assert {[{:p, ["Hello, world"], []}, {:h2, ["Heading 2"], []}], []} ==
      parse("Hello, world\n\n\nHeading 2\n---\n")
  end

  test "does not parse paragraph and h2 with a single blank line" do
    assert {:error, _} = parse("Hello, world\n\nHeading 2\n---\n")
  end

  test "parses h3" do
    assert {[{:h3, ["Heading 3"], []}], []} == parse("\nHeading 3\n...\n")
  end

  test "parses paragraph and h3" do
    assert {[{:p, ["Hello, world"], []}, {:h3, ["Heading 3"], []}], []} ==
      parse("Hello, world\n\n\nHeading 3\n...\n")
  end

  test "does not parse paragraph and h3 with a single blank line" do
    assert {:error, _} = parse("Hello, world\n\nHeading 3\n---\n")
  end

  test "parses text with italics in a paragraph" do
    assert {[{:p, ["example ", {:i, "text"}, "."], []}], []} == parse("example _text_.\n")
  end

  test "parses text with italics at the end" do
    assert {[{:p, ["example ", {:i, "text"}], []}], []} == parse("example _text_\n")
  end

  test "parses text with italics at the start" do
    assert {[{:p, [{:i, "example"}, " text"], []}], []} == parse("_example_ text\n")
  end

  test "parses text with emphases in a paragraph" do
    assert {[{:p, ["example ", {:b, "text"}, "."], []}], []} == parse("example *text*.\n")
  end

  test "parses text with emphasis at the end" do
    assert {[{:p, ["example ", {:b, "text"}], []}], []} == parse("example *text*\n")
  end

  test "parses text with emphasis at the start" do
    assert {[{:p, [{:b, "example"}, " text"], []}], []} == parse("*example* text\n")
  end

  test "parses text with code in a paragraph" do
    assert {[{:p, ["example ", {:code, "text"}, "."], []}], []} == parse("example `text`.\n")
  end

  test "parses text with code at the end" do
    assert {[{:p, ["example ", {:code, "text"}], []}], []} == parse("example `text`\n")
  end

  test "parses text with code at the start" do
    assert {[{:p, [{:code, "example"}, " text"], []}], []} == parse("`example` text\n")
  end

  test "parses links" do
    assert {[{:p, [{:a, "link", "link"}], []}], []} == parse("[[link]]\n")
  end

  test "parses links with references" do
    assert {[{:p, [{:a, "link", "a"}], []}], []} == parse("[[link|a]]\n")
  end

  test "parses text with link at the end" do
    assert {[{:p, ["example ", {:a, "text", "text"}], []}], []} == parse("example [[text]]\n")
  end

  test "parses text with link at the start" do
    assert {[{:p, [{:a, "example", "example"}, " text"], []}], []} == parse("[[example]] text\n")
  end

  test "parses an unordered list" do
    output = {[{:ul, [{:li, ["Item 1"], []},
                     {:li, ["Item 2"], []}], []}], []}
    assert output == parse("  * Item 1\n  * Item 2\n")
  end

  test "parses an ordered list" do
    output = {[{:ol, [{:li, ["Item 1"], []},
                     {:li, ["Item 2"], []}], []}], []}
    assert output == parse(" 1. Item 1\n 2. Item 2\n")
  end

  test "parses an ordered list with big numbers" do
    output = {[{:ol, [{:li, ["Item 1"], []},
                     {:li, ["Item 2"], []}], []}], []}
    assert output == parse("10. Item 1\n12. Item 2\n")
  end

  test "parses code blocks" do
    assert {[{:pre, ["foo bar baz\n  with multiple lines"], []}], []} ==
      parse("    foo bar baz\n      with multiple lines\n")
  end

  test "parses title section" do
    output = {[], [title: "Document: title",
                   author_name: "John Example",
                   author_email: "john@example.com",
                   date: {2016, 3, 21, 12, 0}]}
    input = """
    ::: Document: title
    John Example <john@example.com>, 2016-03-21 12:00
    """
    assert output == parse(input)
  end

  test "parses title section with properties" do
    output = {[], [title: "Document title",
                   author_name: "John Example",
                   author_email: "john@example.com",
                   date: {2016, 3, 21, 12, 0},
                   props: [tags: "foo, bar",
                           descr: "bla"]]}
    input = """
    ::: Document title
    John Example <john@example.com>, 2016-03-21 12:00
    :tags: foo, bar
    :descr: bla
    """
    assert output == parse(input)
  end

  test "parses link references" do
    content = "Paragraph\n\n\n[foo]: bar\n"
    assert {[{:p, ["Paragraph"], []}, {:refs, [{:ref, "foo", "bar"}]}], []} == parse(content)
  end

  test "parses an entire document with title and content" do
    input = fixture("title-and-content.txt")
    output = {[{:p, ["Intro"], []},
               {:h2, ["Heading 2"], []},
               {:p, ["More content"], []}],
              [title: "Document title",
               author_name: "John Example",
               author_email: "john@example.com",
               date: {2016, 3, 21, 12, 0},
               props: [tags: "foo, bar"]]}
    assert output == parse(input)
  end

  test "parses paragraph with class modifiers" do
    assert {[{:p, ["Example"], ["cls"]}], []} == parse(".cls:\nExample\n")
  end

  test "parses blockquotes" do
    assert {[{:blockquote, ["Example quote"], []}], []} == parse("> Example quote\n")
  end

  test "parses full document" do
    input = fixture("full.txt")
    {_content, meta} = parse(input)
    assert Keyword.get(meta, :title) == "Elm: nudging you toward good design"
  end
end
