Definitions.

Mustache = {{\s+[^}]+\s+}}
Atom = [a-zA-Z0-9]
Indent = \n+\s*
TagStart = <{Atom}+\s*
TagClose = </{Atom}+>
Whitespace = (\n|\s|\t)

Rules.

{Mustache} : {token, {mustache, TokenLine, string:trim(TokenChars, both, "{ }")}}.
{TagClose} : {token, {tag_close, TokenLine, string:trim(TokenChars, both, "</>")}}.
{TagStart} : {token, {tag_start, TokenLine, string:trim(TokenChars, both, "< ")}}.
{Indent} : {token, {newline, TokenLine, length(string:trim(TokenChars, leading, "\n")) div 2}}.
{Whitespace} : {token, {whitespace, TokenLine, TokenChars}}.
. : {token, {string, TokenLine, TokenChars}}.

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
parse_indents(P, [{string, Line1, String1} | Acc], [{string, Line2, String2} | T]) ->
  parse_indents(P, [{string, Line1, String1 ++ String2} | Acc], T);
parse_indents(PrevIndent, Acc, [{newline, Line, CurrentIndent} | T]) ->
  Acc1 = case CurrentIndent - PrevIndent of
    N when N > 0 -> lists:duplicate(N, {indent, Line, CurrentIndent}) ++ Acc;
    N when N < 0 -> lists:duplicate(abs(N), {dedent, Line, CurrentIndent}) ++ Acc;
    N when N == 0 -> [{newline, Line, "\n"} | Acc]
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
