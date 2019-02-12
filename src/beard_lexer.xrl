Definitions.


Indent = \n+\s*
TagOpen = <[a-zA-Z0-9]+[^>]*>
TagClose = </[a-zA-Z0-9]+>

Rules.

{TagClose} : {token, {tag_close, TokenLine, string:trim(TokenChars, both, "</>")}}.
{TagOpen} : parse_tag(TokenChars, TokenLine).
{Indent} : {token, {newline, TokenLine, length(string:trim(TokenChars, leading, "\n")) div 2}}.
[^<\n]+? : {token, {string, TokenLine, binary:list_to_bin(TokenChars)}}.

Erlang code.

-export([lex/1]).
-define(VOID_ELEMENTS, ["html", "area", "base", "br", "col", "embed", "hr", "img", 
  "input", "link", "meta", "param", "source", "track", "wbr"]).

lex(String) ->
  {ok, Tokens1, End} = string(String),
  Tokens2 = parse_indents(Tokens1),
  {ok, Tokens2, End}.

parse_indents(Tokens) ->
  parse_indents(0, [], Tokens).
parse_indents(_, Acc, []) ->
  lists:reverse(Acc);
parse_indents(PrevIndent, Acc, [{newline, Line, CurrentIndent} | T]) ->
  Acc1 = case CurrentIndent - PrevIndent of
    N when N > 0 -> lists:duplicate(N, {indent, Line}) ++ Acc;
    N when N < 0 -> lists:duplicate(abs(N), {dedent, Line}) ++ Acc;
    N when N == 0 -> [{newline, Line} | Acc]
  end,
  parse_indents(CurrentIndent, Acc1, T);
parse_indents(P, A, [H | T]) ->
  parse_indents(P, [H | A], T).

parse_tag(Chars, Line) ->
  Trimmed = string:trim(Chars, both, "<>/ "),
  {Tag, Rest} = string:take(Trimmed, " \n", true),
  
  case lists:member(Tag, ?VOID_ELEMENTS) of
    true -> {token, {tag_void, Line, {Tag, Rest}}};
    false -> {token, {tag_open, Line, {Tag, Rest}}}
  end.

close_tags(Tokens) -> close_tags([], [], Tokens).
close_tags([], Acc, []) -> lists:reverse(Acc);
close_tags(Stack, Acc, Tokens) -> Acc.
