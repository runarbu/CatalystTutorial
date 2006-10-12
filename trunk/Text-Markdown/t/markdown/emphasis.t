use Test::More;

eval 'use Test::LongString';
if ($@) {
    plan skip_all => 'Test::LongString required';
} else {
    plan tests => 7;
};

use_ok('Text::Markdown');

my $m = Text::Markdown->new;
my $html;

$html = $m->markdown(<<"EOF");
*single asterisks*

_single underscores_

**double asterisks**

__double underscores__
EOF

is_string($html, <<"EOF");
<p><em>single asterisks</em></p>

<p><em>single underscores</em></p>

<p><strong>double asterisks</strong></p>

<p><strong>double underscores</strong></p>
EOF

$html = $m->markdown(<<"EOF");
*single asterisks_

_single underscores*

*_double asterisks_*

_*double underscores*_
EOF

is_string($html, <<"EOF");
<p>*single asterisks_</p>

<p>_single underscores*</p>

<p><em>_double asterisks_</em></p>

<p><em>*double underscores*</em></p>
EOF

$html = $m->markdown(<<"EOF");
un*fucking*believable
EOF

is_string($html, <<"EOF");
<p>un<em>fucking</em>believable</p>
EOF

$html = $m->markdown(<<"EOF");
un * fucking * believable
EOF

is_string($html, <<"EOF");
<p>un * fucking * believable</p>
EOF

$html = $m->markdown(<<"EOF");
un\\*fucking\\*believable
EOF

is_string($html, <<"EOF");
<p>un*fucking*believable</p>
EOF

$html = $m->markdown(<<"EOF");
\\*this text is surrounded by literal asterisks\\*

EOF

is_string($html, <<"EOF");
<p>*this text is surrounded by literal asterisks*</p>
EOF
