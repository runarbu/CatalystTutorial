use Test::More tests => 3;

use_ok( 'Text::Markdown', 'markdown' );

my $m     = Text::Markdown->new;
my $html1 = $m->markdown(<<"EOF");
Foo

Bar
EOF

is( <<"EOF", $html1 );
<p>Foo</p>

<p>Bar</p>
EOF

my $html2 = markdown(<<"EOF");
Foo

Bar
EOF

is( <<"EOF", $html2 );
<p>Foo</p>

<p>Bar</p>
EOF
