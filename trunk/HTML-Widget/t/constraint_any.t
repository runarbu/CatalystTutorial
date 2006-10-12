use strict;
use warnings;

use Test::More tests => 4;

use HTML::Widget;
use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' );
$w->element( 'Textfield', 'bar' );

$w->constraint( 'Any', 'foo', 'bar' );

# Valid
{
    my $query = HTMLWidget::TestLib->mock_query( { foo => 'yada' } );

    my $f = $w->process($query);

    is( $f->param('foo'), 'yada', 'foo value' );

    ok( !$f->errors, 'no errors' );
}

# Invalid
{
    my $query = HTMLWidget::TestLib->mock_query( { baz => 23 } );

    my $f = $w->process($query);

    ok( $f->errors('foo'), 'foo has errors' );
    ok( $f->errors('bar'), 'bar has errors' );
}
