use Test::More;

eval 'use Test::LongString';
if ($@) {
    plan skip_all => 'Test::LongString required';
} else {
    plan tests => 17;
};

use_ok('Text::Markdown');

my $m = Text::Markdown->new;
my $html;

$html = $m->markdown(<<"EOF");
* Red
* Green
* Blue
EOF

is_string($html, <<"EOF");
<ul>
<li>Red</li>
<li>Green</li>
<li>Blue</li>
</ul>
EOF

$html = $m->markdown(<<"EOF");
+ Red
+ Green
+ Blue
EOF

is_string($html, <<"EOF");
<ul>
<li>Red</li>
<li>Green</li>
<li>Blue</li>
</ul>
EOF

$html = $m->markdown(<<"EOF");
- Red
- Green
- Blue
EOF

is_string($html, <<"EOF");
<ul>
<li>Red</li>
<li>Green</li>
<li>Blue</li>
</ul>
EOF

$html = $m->markdown(<<"EOF");
1. Red
2. Green
3. Blue
EOF

is_string($html, <<"EOF");
<ol>
<li>Red</li>
<li>Green</li>
<li>Blue</li>
</ol>
EOF

$html = $m->markdown(<<"EOF");
1. Red
1. Green
1. Blue
EOF

is_string($html, <<"EOF");
<ol>
<li>Red</li>
<li>Green</li>
<li>Blue</li>
</ol>
EOF

$html = $m->markdown(<<"EOF");
3. Red
1. Green
8. Blue
EOF

is_string($html, <<"EOF");
<ol>
<li>Red</li>
<li>Green</li>
<li>Blue</li>
</ol>
EOF

$html = $m->markdown(<<"EOF");
 * Red
 * Green
 * Blue
EOF

is_string($html, <<"EOF");
<ul>
<li>Red</li>
<li>Green</li>
<li>Blue</li>
</ul>
EOF

$html = $m->markdown(<<"EOF");
*   Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
    Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
    viverra nec, fringilla in, laoreet vitae, risus.
*   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
    Suspendisse id sem consectetuer libero luctus adipiscing.
EOF

is_string($html, <<"EOF");
<ul>
<li>Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
viverra nec, fringilla in, laoreet vitae, risus.</li>
<li>Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
Suspendisse id sem consectetuer libero luctus adipiscing.</li>
</ul>
EOF

$html = $m->markdown(<<"EOF");
*   Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
viverra nec, fringilla in, laoreet vitae, risus.
*   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
Suspendisse id sem consectetuer libero luctus adipiscing.
EOF

is_string($html, <<"EOF");
<ul>
<li>Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
viverra nec, fringilla in, laoreet vitae, risus.</li>
<li>Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
Suspendisse id sem consectetuer libero luctus adipiscing.</li>
</ul>
EOF

$html = $m->markdown(<<"EOF");
*   Bird

*   Magic
EOF

is_string($html, <<"EOF");
<ul>
<li><p>Bird</p></li>
<li><p>Magic</p></li>
</ul>
EOF

$html = $m->markdown(<<"EOF");
1.  This is a list item with two paragraphs. Lorem ipsum dolor
    sit amet, consectetuer adipiscing elit. Aliquam hendrerit
    mi posuere lectus.

    Vestibulum enim wisi, viverra nec, fringilla in, laoreet
    vitae, risus. Donec sit amet nisl. Aliquam semper ipsum
    sit amet velit.

2.  Suspendisse id sem consectetuer libero luctus adipiscing.
EOF

is_string($html, <<"EOF");
<ol>
<li><p>This is a list item with two paragraphs. Lorem ipsum dolor
sit amet, consectetuer adipiscing elit. Aliquam hendrerit
mi posuere lectus.</p>

<p>Vestibulum enim wisi, viverra nec, fringilla in, laoreet
vitae, risus. Donec sit amet nisl. Aliquam semper ipsum
sit amet velit.</p></li>
<li><p>Suspendisse id sem consectetuer libero luctus adipiscing.</p></li>
</ol>
EOF

$html = $m->markdown(<<"EOF");
*   This is a list item with two paragraphs.

    This is the second paragraph in the list item. You're
only required to indent the first line. Lorem ipsum dolor
sit amet, consectetuer adipiscing elit.

*   Another item in the same list.
EOF

is_string($html, <<"EOF");
<ul>
<li><p>This is a list item with two paragraphs.</p>

<p>This is the second paragraph in the list item. You\'re
only required to indent the first line. Lorem ipsum dolor
sit amet, consectetuer adipiscing elit.</p></li>
<li><p>Another item in the same list.</p></li>
</ul>
EOF

$html = $m->markdown(<<"EOF");
*   A list item with a blockquote:

    > This is a blockquote
    > inside a list item.
EOF

is_string($html, <<"EOF");
<ul>
<li><p>A list item with a blockquote:</p>

<blockquote>
  <p>This is a blockquote
  inside a list item.</p>
</blockquote></li>
</ul>
EOF

$html = $m->markdown(<<"EOF");
*   A list item with a code block:

        <code goes here>
EOF

is_string($html, <<"EOF");
<ul>
<li><p>A list item with a code block:</p>

<pre><code>&lt;code goes here&gt;
</code></pre></li>
</ul>
EOF

$html = $m->markdown(<<"EOF");
1986. What a great season.
EOF

is_string($html, <<"EOF");
<ol>
<li>What a great season.</li>
</ol>
EOF

$html = $m->markdown(<<"EOF");
1986\\. What a great season.
EOF

is_string($html, <<"EOF");
<p>1986. What a great season.</p>
EOF
