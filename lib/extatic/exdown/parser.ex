defmodule Extatic.Exdown.Parser do
  def parse(source) do
    with {:ok, tokens, _} <- :exdown_lexer.string(to_charlist(source)),
         {:ok, result} <- :exdown_parser.parse(tokens)
    do
      {:ok, result}
    end
  end
end
