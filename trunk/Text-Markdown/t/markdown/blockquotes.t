use Test::More;

eval 'use Test::LongString';
if ($@) {
    plan skip_all => 'Test::LongString required';
} else {
    plan tests => 5;
};

use_ok('Text::Markdown');

my $m = Text::Markdown->new;
my $html;

$html = $m->markdown(<<"EOF");
> This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
> consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
> Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.
> 
> Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
> id sem consectetuer libero luctus adipiscing.
EOF

is_string($html, <<"EOF");
<blockquote>
  <p>This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
  consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
  Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.</p>
  
  <p>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
  id sem consectetuer libero luctus adipiscing.</p>
</blockquote>
EOF

$html = $m->markdown(<<"EOF");
> This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.

> Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
id sem consectetuer libero luctus adipiscing.
EOF

is_string($html, <<"EOF");
<blockquote>
  <p>This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
  consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
  Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.</p>
  
  <p>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
  id sem consectetuer libero luctus adipiscing.</p>
</blockquote>
EOF

$html = $m->markdown(<<"EOF");
> This is the first level of quoting.
>
> > This is nested blockquote.
>
> Back to the first level.
EOF

is_string($html, <<"EOF");
<blockquote>
  <p>This is the first level of quoting.</p>
  
  <blockquote>
    <p>This is nested blockquote.</p>
  </blockquote>
  
  <p>Back to the first level.</p>
</blockquote>
EOF

$html = $m->markdown(<<"EOF");
> ## This is a header.
> 
> 1.   This is the first list item.
> 2.   This is the second list item.
> 
> Here's some example code:
> 
>     return shell_exec(\"echo \$input | \$markdown_script\");
EOF

is_string($html, <<"EOF");
<blockquote>
  <h2>This is a header.</h2>
  
  <ol>
  <li>This is the first list item.</li>
  <li>This is the second list item.</li>
  </ol>
  
  <p>Here\'s some example code:</p>

<pre><code>return shell_exec(\"echo \$input | \$markdown_script\");
</code></pre>
</blockquote>
EOF
