Nonterminals
content
contents
tag
multiline_content
multiline_contents
block
.

Terminals
indent
dedent
newline
string
tag_void
tag_open
tag_close
.

Rootsymbol multiline_contents.

Nonassoc 100 tag_void string newline.
Right 300 tag_open indent.
Left 400 block tag_close dedent.

% Two different types of tags, one that can have newlines
% that starts with a run of tagopens and contains anything
% One that cannot have newlines that ends with a tag close or a newline

tag -> tag_open contents tag_close : {'$1', '$2'}.
tag -> tag_open block : {'$1', '$2'}.
tag -> tag_open contents : {'$1', '$2'}.

block -> indent multiline_contents dedent : '$2'.

contents -> content : '$1'.
contents -> content contents : ['$1' | '$2'].

multiline_contents -> content : '$1'.
multiline_contents -> content multiline_contents : ['$1' | '$2'].
multiline_contents -> content newline multiline_contents : ['$1' | '$3'].

content -> string : value('$1').
content -> tag_void : value('$1').
content -> tag : value('$1').

Erlang code.

debug({_, _, V} = Value) -> io:format("----------~n~p~n----------", [Value]), V;
debug(Values) -> io:format("----------~n~p~n----------", [Values]), Values.

value({Tag, Contents}) -> {value(Tag), Contents};
value({_, _, {Tag, Attr}}) -> Tag;
value({_, _, V}) -> V.