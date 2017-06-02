defmodule Extatic.Exdown.HtmlFormatter do
  @moduledoc """
  Transform parsed Exdown documents into an HTML file.
  """

  @doc """
  Transform a parsed Exdown document into an HTML fragment or
  entire page.

  ### Examples

      iex> HtmlFormatter.format({[{:p, ["Hello, world"], []}], []})
      {:ok, "<p>Hello, world</p>\\n"}

  """
  @spec format(Extatic.Exdown.Parser.document) :: {:ok, String.t}
  def format({elements, doc}) do
    html = elements
    |> resolve_references
    |> block_format
    |> document(doc)
    {:ok, html}
  end

  defp document(content, []) do
    content
  end

  defp document(content, props) when is_list(props) do
    title = Keyword.get(props, :title)
    """
    <!doctype html>
    <html>
      <head>
        <meta charset="utf-8">
        <title>#{title}</title>
      </head>
      <body>
        <h1>#{title}</h1>
        #{content}
      </body>
    </html>
    """
  end

  defp resolve_references(elements) do
    refs =
      case List.last elements do
        {:refs, r} -> r
        _ -> []
      end
    resolve_references(elements, refs)
  end

  defp resolve_references(elements, refs) do
    Enum.map elements, fn
      {:a, name, ref} ->
        found_ref =
          Enum.find(refs, fn
            {:ref, ^ref, _} ->
              true
            _ ->
              false
          end)
        case found_ref do
          {_, _, url} ->
            {:a, name, url}
          _ ->
            raise "No match found for link #{ref}"
        end
      {el, sub_elements, attrs} when is_list(sub_elements) ->
        {el, resolve_references(sub_elements, refs), attrs}
      other ->
        other
    end
  end


  defp attrs_from_classes([]), do: []
  defp attrs_from_classes(classes), do: [class: Enum.join(classes, " ")]

  defp block_format([{name, content, classes} | rest]) when name in ~w(p h1 h2 h3 pre li)a do
    tag(name, inline_format(content), attrs_from_classes(classes)) <> "\n" <> block_format(rest)
  end

  defp block_format([{name, items, classes} | rest]) when name in ~w(ul ol)a do
    tag(name, block_format(items), attrs_from_classes(classes)) <> "\n" <> block_format(rest)
  end

  defp block_format([{:blockquote, content, classes} | rest]) do
    tag(:blockquote, tag(:p, inline_format(content)), attrs_from_classes(classes)) <> "\n" <> block_format(rest)
  end

  defp block_format([{:refs, _} | rest]) do
    "" <> block_format(rest)
  end

  defp block_format([]) do
    ""
  end

  defp inline_format([str | rest]) when is_binary(str) do
    str <> inline_format(rest)
  end

  defp inline_format([{name, str} | rest]) when name in ~w(i b code)a do
    tag(name, str) <> inline_format(rest)
  end

  defp inline_format([{:a, str, url} | rest]) do
    tag(:a, str, href: url) <> inline_format(rest)
  end

  defp inline_format([]) do
    ""
  end

  defp tag(name, content, attrs \\ []) do
    "<#{name}#{html_attributes(attrs)}>#{content}</#{name}>"
  end

  defp html_attributes(kw) do
    kw
    |> Enum.map(fn {key, value} -> ~s( #{key}="#{value}") end)
    |> Enum.join
  end
end
