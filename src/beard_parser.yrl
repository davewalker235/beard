Nonterminals tag.

Terminals indent erl tag_open tag_start tag_end tag_close string newline.

Rootsymbol tag.

tag ->
  tag_open newline :
  ['$1', '$1'].

Erlang code.

-export([test/0]).

test() ->
  {ok, File} = file:read_file("src/template/layout.html"),
  Template = binary:bin_to_list(File),
  {ok, Tokens, _} = liberty_lexer:string(Template),
  parse(Tokens).


test2() ->
  Tokens = [
    {tag_open, 0, "html"},
    {newline, 0, nil},
    {tag_open, 1, "div"},
    {indent, 2, 1},
    {tag_open, 2, "p"},
    {indent, 3, 1},
    {tag_open, 3, "a"}
  ],
  parse(Tokens).
