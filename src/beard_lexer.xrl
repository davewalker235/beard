Definitions.

Indent = \n+\s*
WhiteSpace = \s+
TagOpen = <[a-zA-Z]+?>\s?
TagStart = <[a-zA-Z]+
TagEnd = >\s?
TagClose = </[a-zA-Z]+?>
Mustache = \{\{[^}]+?\}\}

Rules.

{Indent} : {token, {indent, TokenLine, length(string:trim(TokenChars, leading, "\n")) div 2}}.
{Mustache} : {token, {erl, TokenLine, string:trim(TokenChars, both, "{ }")}}.
{TagOpen} : {token, {tag_open, TokenLine, string:trim(TokenChars, both, "<> ")}}.
{TagStart} : {token, {tag_start, TokenLine, string:trim(TokenChars, leading, "<")}}.
{TagEnd} : {token, {tag_end, TokenLine}}.
{TagClose} : {token, {tag_close, TokenLine, string:trim(TokenChars, both, "<>/")}}.
[^<\n>{}]+ : {token, {string, TokenLine, TokenChars}}.
{WhiteSpace} : skip_token.

Erlang code.

-export([lex/1]).
-define(VOID_ELEMENTS, [area, base, br, col, embed, hr, img, input, link, meta, param, source, track, wbr]).

lex(String) ->
  {ok, Tokens, End} = string(String),
  {ok, parse_indents(0, [], Tokens), End}.

parse_indents(_, Acc, []) -> lists:reverse(Acc);
parse_indents(Prev, Acc, [{indent, Line, Curr} | T]) ->
  Acc1 = case Curr - Prev of
    N when N > 0 -> [{indent, Line, abs(N)} | Acc];
    N when N < 0 -> [{dedent, Line, abs(N)} | Acc];
    N when N == 0 -> [{newline, Line} | Acc]
  end,
  parse_indents(Curr, Acc1, T);
parse_indents(Level1, Acc, [H | T]) ->
  parse_indents(Level1, [H | Acc], T).

parse_tag(Tag) ->
  case lists:member(Tag, ?VOID_ELEMENTS) of
    true -> {tag_void, }
    false -> {tag_open, }
  end.
