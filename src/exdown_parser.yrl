Terminals
',' '<' '>' ':' '|' '[' ']' '_' '*' '`' space char newline h1_underline h2_underline
h3_underline uli oli indented title_marker.

Nonterminals
document paragraph paragraph_contents italic inline_text bold code
h1 h2 h3 block_element ul ul_item ul_items ol ol_items ol_item link pre refs
ref inline_char document_contents title_section title author_email date author_name.

Rootsymbol document.

% Document building blocks
% ------------------------
document ->
    title_section : {[], '$1'}.
document ->
    title_section document_contents : {'$2', '$1'}.
document ->
    document_contents : {'$1', []}.
document_contents ->
    block_element newline document_contents : ['$1' | '$3'].
document_contents ->
    block_element : ['$1'].
block_element ->
    h1 : '$1'.
block_element ->
    h2 : '$1'.
block_element ->
    h3 : '$1'.
block_element ->
    ul : '$1'.
block_element ->
    ol : '$1'.
block_element ->
    pre : '$1'.
block_element ->
    paragraph : '$1'.
block_element ->
    refs : '$1'.

% Title section
% -------------
title_section ->
    title author_name author_email date newline : [{title, '$1'}, {author_name, '$2'}, {author_email, '$3'}, {date, '$4'}].
title ->
    title_marker inline_text newline : '$2'.
author_name ->
    inline_text : binary:list_to_bin(string:strip(binary:bin_to_list('$1'))).
author_email ->
    '<' inline_text '>' : '$2'.
date ->
    ',' space inline_text : parse_datetime('$3').

% Headings
% --------
h1 ->
    paragraph_contents newline h1_underline : {h1, '$1'}.
h2 ->
    newline paragraph_contents newline h2_underline : {h2, '$2'}.
h3 ->
    newline paragraph_contents newline h3_underline : {h3, '$2'}.

% Unordered lists
% ---------------
ul ->
    ul_items : {ul, '$1'}.
ul_items ->
    ul_item ul_items : ['$1' | '$2'].
ul_items ->
    ul_item : ['$1'].
ul_item ->
    uli paragraph_contents newline : {li, '$2'}.

% Ordered lists
% ---------------
ol ->
    ol_items : {ol, '$1'}.
ol_items ->
    ol_item ol_items : ['$1' | '$2'].
ol_items ->
    ol_item : ['$1'].
ol_item ->
    oli paragraph_contents newline : {li, '$2'}.

% Paragraphs
% ---------------
paragraph ->
    paragraph_contents newline : {p, '$1'}.
paragraph_contents ->
    inline_text paragraph_contents : ['$1' | '$2'].
paragraph_contents ->
    italic paragraph_contents : ['$1' | '$2'].
paragraph_contents ->
    italic : ['$1'].
paragraph_contents ->
    link paragraph_contents : ['$1' | '$2'].
paragraph_contents ->
    link : ['$1'].
paragraph_contents ->
    code paragraph_contents : ['$1' | '$2'].
paragraph_contents ->
    code : ['$1'].
paragraph_contents ->
    bold paragraph_contents : ['$1' | '$2'].
paragraph_contents ->
    bold : ['$1'].
paragraph_contents ->
    inline_text : ['$1'].

% Indented code blocks
% --------------------
pre ->
    indented : {pre, list_to_binary(extract_value('$1'))}.

% Inline formatting
% --------------
italic ->
    '_' inline_text '_' : {i, '$2'}.
bold ->
    '*' inline_text '*' : {b, '$2'}.
code ->
    '`' inline_text '`' : {code, '$2'}.
link ->
    '[' '[' inline_text '|' inline_text ']' ']' : {a, '$3', '$5'}.
link ->
    '[' '[' inline_text ']' ']' : {a, '$3', '$3'}.

% Link refs
% ---------
refs ->
    ref refs : ['$1' | '$2'].
refs ->
    ref : ['$1'].
ref ->
    '[' inline_text ']' ':' space inline_text newline : {ref, '$2', '$6'}.

% Inline text without formatting
% ------------------------------
inline_text ->
    inline_char inline_text : concat('$1', '$2').
inline_text ->
    inline_char : '$1'.
inline_char ->
    space : binary:list_to_bin(" ").
inline_char ->
    ',' : binary:list_to_bin(",").
inline_char ->
    ':' : binary:list_to_bin(":").
inline_char ->
    char : extract_string('$1').

Erlang code.

extract_value({_, _, Value}) ->
    Value.

extract_string(Token) ->
    list_to_binary(extract_value(Token)).

concat(A, B) ->
    <<A/binary, B/binary>>.

parse_integers([Chars | Rest]) when is_list(Chars)->
    [list_to_integer(Chars) | parse_integers(Rest)];

parse_integers([]) ->
    [].

parse_datetime(Chars) ->
    list_to_tuple(parse_integers(string:tokens(binary:bin_to_list(Chars), "- :"))).
