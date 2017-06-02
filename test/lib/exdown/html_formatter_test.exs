defmodule Extatic.Exdown.HtmlFormatterTest do
  use ExUnit.Case, async: true

  alias Extatic.Exdown.HtmlFormatter
  doctest HtmlFormatter

  def to_html(input) do
    with {:ok, output} <- HtmlFormatter.format(input) do
      output
    end
  end

  test "formats a paragraph" do
    assert "<p>Hello</p>\n" == to_html({[{:p, ["Hello"], []}], []})
  end

  test "formats a paragraph with classes" do
    assert ~s(<p class="foo bar">Hello</p>\n) == to_html({[{:p, ["Hello"], ["foo", "bar"]}], []})
  end

  test "errors when link refs cannot be found" do
    assert_raise RuntimeError, "No match found for link bar", fn ->
      to_html({[{:p, ["Hello ", {:a, "foo", "bar"}], []}, {:refs, []}], []})
    end
  end

  test "formats multiple paragraphs" do
    assert "<p>Hello</p>\n<p>Again</p>\n" ==
      to_html({[{:p, ["Hello"], []}, {:p, ["Again"], []}], []})
  end

  test "formats blockquotes" do
    assert "<blockquote><p>Hello</p></blockquote>\n" ==
      to_html({[{:blockquote, ["Hello"], []}], []})
  end

  test "formats paragraphs with links using their URL" do
    assert "<p>Hello <a href=\"qux\">foo</a></p>\n" ==
      to_html({[{:p, ["Hello ", {:a, "foo", "bar"}], []}, {:refs, [{:ref, "bar", "qux"}]}], []})
  end

  test "formats paragraphs with inline formatting" do
    assert "<p>Hello <i>world</i></p>\n" ==
      to_html({[{:p, ["Hello ", {:i, "world"}], []}], []})
    assert "<p>Hello <b>world</b></p>\n" ==
      to_html({[{:p, ["Hello ", {:b, "world"}], []}], []})
    assert "<p>Hello <code>world</code></p>\n" ==
      to_html({[{:p, ["Hello ", {:code, "world"}], []}], []})
  end

  test "formats headings" do
    assert "<h1>1</h1>\n" == to_html({[{:h1, ["1"], []}], []})
    assert "<h2>2</h2>\n" == to_html({[{:h2, ["2"], []}], []})
    assert "<h3>3</h3>\n" == to_html({[{:h3, ["3"], []}], []})
  end

  test "formats code blocks" do
    assert "<pre>foo</pre>\n" == to_html({[{:pre, ["foo"], []}], []})
  end

  test "formats unordered lists" do
    assert "<ul><li>A</li>\n<li>B</li>\n</ul>\n" ==
      to_html({[{:ul, [{:li, ["A"], []}, {:li, ["B"], []}], []}], []})
  end

  test "formats ordered lists" do
    assert "<ol><li>A</li>\n<li>B</li>\n</ol>\n" ==
      to_html({[{:ol, [{:li, ["A"], []}, {:li, ["B"], []}], []}], []})
  end
end
