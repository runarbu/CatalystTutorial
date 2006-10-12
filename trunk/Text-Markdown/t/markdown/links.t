use Test::More;

eval 'use Test::LongString';
if ($@) {
    plan skip_all => 'Test::LongString required';
} else {
    plan tests => 20;
};

use_ok('Text::Markdown');

my $m = Text::Markdown->new;
my $html;

$html = $m->markdown(<<"EOF");
This is [an example](http://example.com/ "Title") inline link.

[This link](http://example.net/) has no title attribute.
EOF

is_string($html, <<"EOF");
<p>This is <a href="http://example.com/" title="Title">an example</a> inline link.</p>

<p><a href="http://example.net/">This link</a> has no title attribute.</p>
EOF

$html = $m->markdown(<<"EOF");
See my [About](/about/) page for details.
EOF

is_string($html, <<"EOF");
<p>See my <a href="/about/">About</a> page for details.</p>
EOF

$html = $m->markdown(<<"EOF");
[id]: http://example.com/  "Optional Title Here"
This is [an example][id] reference-style link.
EOF

is_string($html, <<"EOF");
<p>This is <a href="http://example.com/" title="Optional Title Here">an example</a> reference-style link.</p>
EOF

$html = $m->markdown(<<"EOF");
[id]: http://example.com/  "Optional Title Here"
This is [an example] [id] reference-style link.
EOF

is_string($html, <<"EOF");
<p>This is <a href="http://example.com/" title="Optional Title Here">an example</a> reference-style link.</p>
EOF

$html = $m->markdown(<<"EOF");
This is [an example][id] reference-style link.
EOF

is_string($html, <<"EOF");
<p>This is [an example][id] reference-style link.</p>
EOF

$html = $m->markdown(<<"EOF");
This is [an example] [id] reference-style link.
EOF

is_string($html, <<"EOF");
<p>This is [an example] [id] reference-style link.</p>
EOF

$html = $m->markdown(<<"EOF");
[foo]: http://example.com/  "Optional Title Here"

[bar]: http://example.com/  'Optional Title Here'

[baz]: http://example.com/  (Optional Title Here)

[a][foo]

[b][bar]

[c][baz]
EOF

is_string($html, <<"EOF");
<p><a href="http://example.com/" title="Optional Title Here">a</a></p>

<p><a href="http://example.com/" title="Optional Title Here">b</a></p>

<p><a href="http://example.com/" title="Optional Title Here">c</a></p>
EOF

$html = $m->markdown(<<"EOF");
[foo]: <http://example.com/>  "Optional Title Here"

[bar]: <http://example.com/>  'Optional Title Here'

[baz]: <http://example.com/>  (Optional Title Here)

[a][foo]

[b][bar]

[c][baz]
EOF

is_string($html, <<"EOF");
<p><a href="http://example.com/" title="Optional Title Here">a</a></p>

<p><a href="http://example.com/" title="Optional Title Here">b</a></p>

<p><a href="http://example.com/" title="Optional Title Here">c</a></p>
EOF

$html = $m->markdown(<<"EOF");
[foo]: <http://example.com/>
    "Optional Title Here"

[bar]: <http://example.com/>
    'Optional Title Here'

[baz]: <http://example.com/>
    (Optional Title Here)

[a][foo]

[b][bar]

[c][baz]
EOF

is_string($html, <<"EOF");
<p><a href="http://example.com/" title="Optional Title Here">a</a></p>

<p><a href="http://example.com/" title="Optional Title Here">b</a></p>

<p><a href="http://example.com/" title="Optional Title Here">c</a></p>
EOF

$html = $m->markdown(<<"EOF");
[id]: http://example.com/  "Optional Title Here"
This is [an example][ID] reference-style link.
EOF

is_string($html, <<"EOF");
<p>This is <a href="http://example.com/" title="Optional Title Here">an example</a> reference-style link.</p>
EOF

$html = $m->markdown(<<"EOF");
[i d]: http://example.com/  "Optional Title Here"
This is [an example][I D] reference-style link.
EOF

is_string($html, <<"EOF");
<p>This is <a href="http://example.com/" title="Optional Title Here">an example</a> reference-style link.</p>
EOF

$html = $m->markdown(<<"EOF");
[2id4]: http://example.com/  "Optional Title Here"
This is [an example][2id4] reference-style link.
EOF

is_string($html, <<"EOF");
<p>This is <a href="http://example.com/" title="Optional Title Here">an example</a> reference-style link.</p>
EOF

$html = $m->markdown(<<"EOF");
[Google]: http://google.com/
[Google][]
EOF

is_string($html, <<"EOF");
<p><a href="http://google.com/">Google</a></p>
EOF

$html = $m->markdown(<<"EOF");
[Daring Fireball]: http://daringfireball.net/
Visit [Daring Fireball][] for more information.
EOF

is_string($html, <<"EOF");
<p>Visit <a href="http://daringfireball.net/">Daring Fireball</a> for more information.</p>
EOF

$html = $m->markdown(<<"EOF");
I get 10 times more traffic from [Google] [1] than from
[Yahoo] [2] or [MSN] [3].

  [1]: http://google.com/        "Google"
  [2]: http://search.yahoo.com/  "Yahoo Search"
  [3]: http://search.msn.com/    "MSN Search"
EOF

is_string($html, <<"EOF");
<p>I get 10 times more traffic from <a href="http://google.com/" title="Google">Google</a> than from
<a href="http://search.yahoo.com/" title="Yahoo Search">Yahoo</a> or <a href="http://search.msn.com/" title="MSN Search">MSN</a>.</p>
EOF

$html = $m->markdown(<<"EOF");
I get 10 times more traffic from [Google][] than from
[Yahoo][] or [MSN][].

  [google]: http://google.com/        "Google"
  [yahoo]:  http://search.yahoo.com/  "Yahoo Search"
  [msn]:    http://search.msn.com/    "MSN Search"
EOF

is_string($html, <<"EOF");
<p>I get 10 times more traffic from <a href="http://google.com/" title="Google">Google</a> than from
<a href="http://search.yahoo.com/" title="Yahoo Search">Yahoo</a> or <a href="http://search.msn.com/" title="MSN Search">MSN</a>.</p>
EOF


$html = $m->markdown(<<"EOF");
I get 10 times more traffic from [Google](http://google.com/ "Google") than from
[Yahoo](http://search.yahoo.com/ "Yahoo Search") or [MSN](http://search.msn.com/ "MSN Search").
EOF

is_string($html, <<"EOF");
<p>I get 10 times more traffic from <a href="http://google.com/" title="Google">Google</a> than from
<a href="http://search.yahoo.com/" title="Yahoo Search">Yahoo</a> or <a href="http://search.msn.com/" title="MSN Search">MSN</a>.</p>
EOF

$html = $m->markdown(<<"EOF");
<http://example.com/>
EOF

is_string($html, <<"EOF");
<p><a href="http://example.com/">http://example.com/</a></p>
EOF

eval 'require HTML::Entities';
SKIP: {
    skip 'HTML::Entitites not installed', 1 if $@; 

$html = $m->markdown(<<"EOF");
<address\@example.com>
EOF

is_string(HTML::Entities::decode_entities($html), <<"EOF");
<p><a href="mailto:address\@example.com">address\@example.com</a></p>
EOF

};





