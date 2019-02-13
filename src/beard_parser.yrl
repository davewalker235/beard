Nonterminals
content
contents
tag
multiline_contents
block
.

Terminals
string
mustache
indent
dedent
newline
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

contents -> content : ['$1'].
contents -> content contents : ['$1' | '$2'].

multiline_contents -> content : ['$1'].
multiline_contents -> content multiline_contents : ['$1' | '$2'].
multiline_contents -> content newline multiline_contents : ['$1' | '$3'].

content -> string : '$1'.
content -> tag_void : '$1'.
content -> tag : '$1'.
content -> mustache : '$1'.

Erlang code.

value({Tag, Contents}) -> {Tag, Contents};
value({_, _, {Tag, Attr}}) -> Tag;
value({_, _, V}) -> V.
