Definitions.

OLI = (\s|[0-9])[0-9]\.\s
ULI = \s\s\*\s
H1L = ===+\n
H2L = ---+\n
H3L = \.\.\.+\n
TITLE = :::\s
SYMBOL = [_*`\[\]|:<>,]
INDENTED = \s\s\s\s.+\n

Rules.

({INDENTED})+ : {token, {indented, TokenLine, extract_code(TokenChars)}}.
{OLI}         : {token, {oli, TokenLine}}.
{ULI}         : {token, {uli, TokenLine}}.
{H1L}         : {token, {h1_underline, TokenLine}}.
{H2L}         : {token, {h2_underline, TokenLine}}.
{H3L}         : {token, {h3_underline, TokenLine}}.
{TITLE}       : {token, {title_marker, TokenLine}}.
{SYMBOL}      : {token, {list_to_atom(TokenChars), TokenLine}}.
\n            : {token, {newline, TokenLine}}.
\s            : {token, {space, TokenLine}}.
.             : {token, {char, TokenLine, TokenChars}}.

Erlang code.

strip_indentation([Line | Rest]) when is_list(Line) ->
    [strip_indentation(Line) | strip_indentation(Rest)];

strip_indentation([]) ->
    [];

strip_indentation(Chars) when is_list(Chars) ->
    lists:sublist(Chars, 5, length(Chars) - 4).

extract_code(Chars) ->
    lists:join("\n", strip_indentation(string:tokens(Chars, "\n"))).
