-module(beard).
-export([test/0]).

test() ->
  {ok, File} = file:read_file("src/layout.html"),
  Template = binary:bin_to_list(File),
  {ok, Tokens, _} = beard_lexer:lex(Template),
  io:format("-------TOKENS--------~n~p~n", [Tokens]),
  {ok, Tree} = beard_parser:parse(Tokens),
  io:format("~n~p~n", [Tree]).
