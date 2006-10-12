use Test::More;

eval 'use Test::LongString';
if ($@) {
    plan skip_all => 'Test::LongString required';
} else {
    plan tests => 6;
};

use_ok('Text::Markdown');

my $m = Text::Markdown->new;
my $html;

$html = $m->markdown(<<"EOF");
* * *
EOF

is_string($html, <<"EOF");
<hr />
EOF

$html = $m->markdown(<<"EOF");
***
EOF

is_string($html, <<"EOF");
<hr />
EOF

$html = $m->markdown(<<"EOF");
*****
EOF

is_string($html, <<"EOF");
<hr />
EOF

$html = $m->markdown(<<"EOF");
- - -
EOF

is_string($html, <<"EOF");
<hr />
EOF

$html = $m->markdown(<<"EOF");
---------------------------------------
EOF

is_string($html, <<"EOF");
<hr />
EOF
