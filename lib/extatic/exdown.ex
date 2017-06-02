defmodule Extatic.Exdown do
  alias Extatic.Exdown.{Parser, HtmlFormatter}

  def to_html(source) do
    with {:ok, parsed} <- Parser.parse(source),
         {:ok, html} <- HtmlFormatter.format(parsed)
    do
      html
    end
  end
end
