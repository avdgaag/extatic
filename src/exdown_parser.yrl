Terminals
'.' ',' '<' '>' ':' '[' ']' '*' space char newline h1_underline h2_underline
h3_underline uli oli indented title_marker italic bold code link property.

Nonterminals
document paragraph paragraph_contents inline_text
h1 h2 h3 block_element ul ul_item ul_items ol ol_items ol_item pre refs
ref inline_char document_contents title_section title author_email date
author_name plain_text plain_text_char main_title_section properties
single_property block_element_wrapper block_metadata class_name refs_content
blockquote.

Rootsymbol document.

% Document building blocks
% ------------------------
document ->
    title_section : {[], '$1'}.
document ->
    title_section newline document_contents : {'$3', '$1'}.
document ->
    document_contents : {'$1', []}.
document_contents ->
    block_element_wrapper newline document_contents : ['$1' | '$3'].
document_contents ->
    newline refs : ['$2'].
document_contents ->
    block_element_wrapper : ['$1'].

% Link refs
% ---------
refs ->
    refs_content : {refs, '$1'}.
refs_content ->
    ref refs_content : ['$1' | '$2'].
refs_content ->
    ref : ['$1'].
ref ->
    '[' plain_text ']' ':' space plain_text newline : {ref, '$2', '$6'}.

% Block element wrappers with metadata
% ------------------------------------
block_element_wrapper ->
    block_metadata newline block_element : add_metadata('$3', '$1').
block_metadata ->
    '.' class_name block_metadata : ['$2' | '$3'].
block_metadata ->
    '.' class_name ':' : ['$2'].
class_name ->
    char class_name : concat(extract_string('$1'), '$2').
class_name ->
    char : extract_string('$1').
block_element_wrapper ->
    block_element : add_metadata('$1', []).


% Block elements
% --------------
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
    blockquote : '$1'.
block_element ->
    paragraph : '$1'.

% Blockquotes
% -----------
blockquote ->
    '>' space paragraph_contents newline : {blockquote, '$3'}.

% Title section
% -------------
title_section ->
    main_title_section properties : lists:append('$1', [{props, '$2'}]).
title_section ->
    main_title_section : '$1'.
main_title_section ->
    title author_name author_email date newline : [{title, '$1'}, {author_name, '$2'}, {author_email, '$3'}, {date, '$4'}].
title ->
    title_marker inline_text newline : '$2'.
author_name ->
    plain_text : binary:list_to_bin(string:strip(binary:bin_to_list('$1'))).
author_email ->
    '<' plain_text '>' : '$2'.
date ->
    ',' space inline_text : parse_datetime('$3').

% Property list
% -------------
properties ->
    single_property properties : ['$1' | '$2'].
properties ->
    single_property : ['$1'].
single_property ->
    property inline_text newline : {extract_value('$1'), '$2'}.

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
    uli paragraph_contents newline : {li, '$2', []}.

% Ordered lists
% ---------------
ol ->
    ol_items : {ol, '$1'}.
ol_items ->
    ol_item ol_items : ['$1' | '$2'].
ol_items ->
    ol_item : ['$1'].
ol_item ->
    oli paragraph_contents newline : {li, '$2', []}.

% Paragraphs
% ---------------
paragraph ->
    paragraph_contents newline : {p, '$1'}.
paragraph_contents ->
    inline_text paragraph_contents : ['$1' | '$2'].
paragraph_contents ->
    italic paragraph_contents : [{i, extract_value('$1')} | '$2'].
paragraph_contents ->
    italic : [{i, extract_value('$1')}].
paragraph_contents ->
    link paragraph_contents : [link_from_token('$1') | '$2'].
paragraph_contents ->
    link : [link_from_token('$1')].
paragraph_contents ->
    code paragraph_contents : [{code, extract_value('$1')} | '$2'].
paragraph_contents ->
    code : [{code, extract_value('$1')}].
paragraph_contents ->
    bold paragraph_contents : [{b, extract_value('$1')} | '$2'].
paragraph_contents ->
    bold : [{b, extract_value('$1')}].
paragraph_contents ->
    inline_text : ['$1'].

% Indented code blocks
% --------------------
pre ->
    indented : {pre, [list_to_binary(extract_value('$1'))]}.

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
    '*' : binary:list_to_bin("*").
inline_char ->
    '>' : binary:list_to_bin(">").
inline_char ->
    '<' : binary:list_to_bin("<").
inline_char ->
    '[' : binary:list_to_bin("[").
inline_char ->
    ']' : binary:list_to_bin("]").
inline_char ->
    '.' : binary:list_to_bin(".").
inline_char ->
    char : extract_string('$1').

plain_text ->
    plain_text_char plain_text : concat('$1', '$2').
plain_text ->
    plain_text_char : '$1'.
plain_text_char ->
    space : binary:list_to_bin(" ").
plain_text_char ->
    '.' : binary:list_to_bin(".").
plain_text_char ->
    ':' : binary:list_to_bin(":").
plain_text_char ->
    char : extract_string('$1').


Erlang code.

extract_value({_, _, Value}) ->
    Value.

extract_string(Token) ->
    unicode:characters_to_binary(extract_value(Token)).

concat(A, B) ->
    <<A/binary, B/binary>>.

parse_integers([Chars | Rest]) when is_list(Chars)->
    [list_to_integer(Chars) | parse_integers(Rest)];

parse_integers([]) ->
    [].

parse_datetime(Chars) ->
    list_to_tuple(parse_integers(string:tokens(binary:bin_to_list(Chars), "- :"))).

link_from_token({_, _, {Text, Ref}}) ->
    {a, Text, Ref}.

add_metadata({A, B}, Metadata) ->
    {A, B, Metadata}.
