use strict;
use warnings;

use Test::More tests => 8;

use HTML::Widget;
use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' );
$w->element( 'Textfield', 'bar' );

$w->constraint( 'Equal', 'foo', 'bar' );

# Valid
{
    my $query = HTMLWidget::TestLib->mock_query( {
            foo => 'yada',
            bar => 'yada',
        } );

    my $f = $w->process($query);

    is( $f->param('foo'), 'yada', 'foo value' );

    is( $f->param('foo'), $f->param('bar'), 'foo eq bar' );

    ok( !$f->errors, 'no errors' );
}

# Valid (blank 1)
SKIP: {
    skip "drunken feature", 1;
    my $query = HTMLWidget::TestLib->mock_query( {
            foo => '',
            bar => 'yada',
        } );

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form id="widget" method="post"><fieldset class="widget_fieldset"><input class="textfield" id="widget_foo" name="foo" type="text" /><input class="textfield" id="widget_bar" name="bar" type="text" value="yada" /></fieldset></form>
EOF
}

# Valid (blank 2)
SKIP: {
    skip "drunken feature", 1;
    my $query = HTMLWidget::TestLib->mock_query( {
            foo => 'yada',
            bar => '',
        } );

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form id="widget" method="post"><fieldset class="widget_fieldset"><input class="textfield" id="widget_foo" name="foo" type="text" value="yada" /><input class="textfield" id="widget_bar" name="bar" type="text" /></fieldset></form>
EOF
}

# Invalid
{
    my $query = HTMLWidget::TestLib->mock_query( {
            foo   => 'yada',
            'bar' => 'nada',
        } );

    my $f = $w->process($query);

    is( $f->param('foo'), 'yada', 'foo value' );

    isnt( $f->param('foo'), $f->param('bar'), 'foo ne bar' );

    ok( $f->errors('bar'), 'bar has errors' );
}
