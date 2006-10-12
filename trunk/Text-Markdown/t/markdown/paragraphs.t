use Test::More;

eval 'use Test::LongString';
if ($@) {
    plan skip_all => 'Test::LongString required';
} else {
    plan tests => 2;
};

use_ok('Text::Markdown');

my $m = Text::Markdown->new;
my $html;

$html = $m->markdown(<<"EOF");
This is a paragraph.

This is a hard-wrapped
paragraph.
EOF

is_string($html, <<"EOF");
<p>This is a paragraph.</p>

<p>This is a hard-wrapped
paragraph.</p>
EOF
