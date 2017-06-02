defmodule Extatic.Exdown.Parser do
  @moduledoc """
  Take a source Exdown file and parse it into an Elixir data structure.  To
  transform that structure into an HTML file, see
  `Extatic.Exdown.HtmlFormatter`.
  """

  @type document :: {list, Keyword.t}

  @doc """
  Parse plain text in Exdown format into an Elixir data structure.

  ### Examples

      iex> Parser.parse("Hello, world\\n")
      {:ok, {[{:p, ["Hello, world"], []}], []}}

  """
  @spec parse(String.t) :: {:ok, document}
  def parse(source) do
    with {:ok, tokens, _} <- :exdown_lexer.string(to_charlist(source)),
         {:ok, result} <- :exdown_parser.parse(tokens)
    do
      {:ok, result}
    end
  end
end
