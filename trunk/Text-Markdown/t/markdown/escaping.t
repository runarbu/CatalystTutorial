use Test::More;

eval 'use Test::LongString';
if ($@) {
    plan skip_all => 'Test::LongString required';
} else {
    plan tests => 13;
};

use_ok('Text::Markdown');

my $m = Text::Markdown->new;
my $html;

$html = $m->markdown(<<"EOF");
&lt; &amp; &copy; & < AT&T 4 < 5

http://images.google.com/images?num=30&q=larry+bird

<a href="http://images.google.com/images?num=30&q=larry+bird"></a>

`&lt; &amp; &copy; < &`

    &lt; &amp; &copy; < &
EOF

is_string($html, <<"EOF");
<p>&lt; &amp; &copy; &amp; &lt; AT&amp;T 4 &lt; 5</p>

<p>http://images.google.com/images?num=30&amp;q=larry+bird</p>

<p><a href="http://images.google.com/images?num=30&amp;q=larry+bird"></a></p>

<p><code>&amp;lt; &amp;amp; &amp;copy; &lt; &amp;</code></p>

<pre><code>&amp;lt; &amp;amp; &amp;copy; &lt; &amp;
</code></pre>
EOF

$html = $m->markdown(<<"EOF");
\\*literal asterisks\\*
EOF

is_string($html, <<"EOF");
<p>*literal asterisks*</p>
EOF

$html = $m->markdown(<<"EOF");
\\ ` * _ {} [] () # . !
EOF

is_string($html, <<"EOF");
<p>\\ ` * _ {} [] () # . !</p>
EOF

$html = $m->markdown(<<"EOF");
\\`literal\\`
EOF

is_string($html, <<"EOF");
<p>`literal`</p>
EOF

$html = $m->markdown(<<"EOF");
\\*literal\\*
EOF

is_string($html, <<"EOF");
<p>*literal*</p>
EOF

$html = $m->markdown(<<"EOF");
\\!literal\\!
EOF

is_string($html, <<"EOF");
<p>!literal!</p>
EOF

$html = $m->markdown(<<"EOF");
\\.literal\\.
EOF

is_string($html, <<"EOF");
<p>.literal.</p>
EOF

$html = $m->markdown(<<"EOF");
\\#literal\\#
EOF

is_string($html, <<"EOF");
<p>#literal#</p>
EOF

$html = $m->markdown(<<"EOF");
\\(literal\\)
EOF

is_string($html, <<"EOF");
<p>(literal)</p>
EOF

$html = $m->markdown(<<"EOF");
\\[literal\\]
EOF

is_string($html, <<"EOF");
<p>[literal]</p>
EOF

$html = $m->markdown(<<"EOF");
\\{literal\\}
EOF

is_string($html, <<"EOF");
<p>{literal}</p>
EOF

$html = $m->markdown(<<"EOF");
\\_literal\\_
EOF

is_string($html, <<"EOF");
<p>_literal_</p>
EOF











