Definitions.

OLI = (\s|[0-9])[0-9]\.\s
ULI = \s\s\*\s
H1L = ===+\n
H2L = ---+\n
H3L = \.\.\.+\n
TITLE = :::\s
SYMBOL = [*\[\]:<>,\.]
INDENTED = \s\s\s\s.+\n
ITALIC = _[a-zA_Z0-9].*_
BOLD = \*[a-zA_Z0-9].*\*
CODE = `[a-zA_Z0-9].*`
LINK = \[\[[^\]]+\]\]

Rules.

:[a-z]+:\s     : {token, {property, TokenLine, extract_prop(TokenChars)}}.
{ITALIC}       : {token, {italic, TokenLine, extract_text(TokenChars)}}.
{BOLD}         : {token, {bold, TokenLine, extract_text(TokenChars)}}.
{CODE}         : {token, {code, TokenLine, extract_text(TokenChars)}}.
{LINK}         : {token, {link, TokenLine, extract_link(TokenChars)}}.
({INDENTED})+  : {token, {indented, TokenLine, extract_code(TokenChars)}}.
{OLI}          : {token, {oli, TokenLine}}.
{ULI}          : {token, {uli, TokenLine}}.
{H1L}          : {token, {h1_underline, TokenLine}}.
{H2L}          : {token, {h2_underline, TokenLine}}.
{H3L}          : {token, {h3_underline, TokenLine}}.
{TITLE}        : {token, {title_marker, TokenLine}}.
{SYMBOL}       : {token, {list_to_atom(TokenChars), TokenLine}}.
\n             : {token, {newline, TokenLine}}.
\s             : {token, {space, TokenLine}}.
.              : {token, {char, TokenLine, TokenChars}}.

Erlang code.

strip_indentation([Line | Rest]) when is_list(Line) ->
    [strip_indentation(Line) | strip_indentation(Rest)];

strip_indentation([]) ->
    [];

strip_indentation(Chars) when is_list(Chars) ->
    lists:sublist(Chars, 5, length(Chars) - 4).

extract_code(Chars) ->
    lists:join("\n", strip_indentation(string:tokens(Chars, "\n"))).

extract_text(Chars) ->
    binary:list_to_bin(lists:sublist(Chars, 2, length(Chars) - 2)).

extract_prop(Chars) ->
    list_to_atom(lists:sublist(Chars, 2, length(Chars) - 3)).

split_link_ref([First, Rest]) ->
    {binary:list_to_bin(First), binary:list_to_bin(Rest)};

split_link_ref([First]) ->
    {binary:list_to_bin(First), binary:list_to_bin(First)}.

extract_link(Chars) ->
    split_link_ref(string:tokens(lists:sublist(Chars, 3, length(Chars) - 4), "|")).
