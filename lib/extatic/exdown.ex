defmodule Extatic.Exdown do
  def parse(source) do
    with {:ok, tokens, _} <- :exdown_lexer.string(to_charlist(source)),
         {:ok, result} <- :exdown_parser.parse(tokens)
    do
      result
    end
  end
end
