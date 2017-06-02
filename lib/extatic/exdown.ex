defmodule Extatic.Exdown do
  @moduledoc """
  Exdown is a custom plain text markup format, much like Markdown and AsciiDoc,
  that allows you to write human-friendly plain text and transform it into HTML.

  ## Outputs

  Currently only HTML output is implemented, but the parsing and formatting
  steps are decoupled so it should be easy enough to implement your own custom
  formatter using `Extatic.Exdown.Parser.parse/1`.

  ## Example document

  A simple document looks much like Markdown:

      Hello, world! We're _excited_ to see you!

  Transforming it gives us:

      iex> Exdown.to_html("Hello, world! We're _excited_ to see you!\\n")
      "<p>Hello, world! We're <i>excited</i> to see you!</p>\\n"

  Here's a more elaborate example:

      ::: Elm: nudging you toward good design
      Arjan van der Gaag <arjan@arjanvandergaag.nl>, 2016-05-30 12:00
      :tags: programming, elm

      .leader:
      Elm is a functional programming language that compiles to javascript.


      The best of functional programming in your browser
      --------------------------------------------------

      [[Elm]] promises to deliver fast, virtual DOM-based HTML apps with no
      runtime exceptions.


      [Elm]: http://elm-lang.org

  This example includes an explicit title with author information, front matter,
  subheadings, links and a paragraph with a custom class name of `leader`.

  """

  alias Extatic.Exdown.{Parser, HtmlFormatter}

  @doc """
  Transform an Exdown source file in plain text and transform it into
  HTML output.

  ### Examples

      iex> Exdown.to_html("Hello, world!\\n")
      "<p>Hello, world!</p>\\n"

  """
  @spec to_html(String.t) :: String.t
  def to_html(source) do
    with {:ok, parsed} <- Parser.parse(source),
         {:ok, html} <- HtmlFormatter.format(parsed)
    do
      html
    end
  end
end
