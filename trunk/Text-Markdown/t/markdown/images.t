use Test::More;

eval 'use Test::LongString';
if ($@) {
    plan skip_all => 'Test::LongString required';
} else {
    plan tests => 3;
};

use_ok('Text::Markdown');

my $m = Text::Markdown->new;
my $html;

$html = $m->markdown(<<"EOF");
![Alt text](/path/to/img.jpg)

![Alt text](/path/to/img.jpg "Optional title")
EOF

is_string($html, <<"EOF");
<p><img src="/path/to/img.jpg" alt="Alt text" title="" /></p>

<p><img src="/path/to/img.jpg" alt="Alt text" title="Optional title" /></p>
EOF

$html = $m->markdown(<<"EOF");
[id]: url/to/image  "Optional title attribute"
![Alt text][id]
EOF

is_string($html, <<"EOF");
<p><img src="url/to/image" alt="Alt text" title="Optional title attribute" /></p>
EOF
