use Test::More tests => 2;

use_ok('HTML::Widget');

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' )->value( 0 );

$w->constraint( 'All', 'foo' );

my $f = $w->process();
is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="0" /></fieldset></form>
EOF
