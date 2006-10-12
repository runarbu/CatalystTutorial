use Test::More tests => 4;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w1 = HTML::Widget->new;

$w1->element( 'Textfield', 'foo' );
$w1->element( 'Textfield', '0' );

# Valid
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'yada',
        0   => 'a',
    });

    my $result = $w1->process($query);

    is( "$result", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="yada" /><input class="textfield" id="widget_0" name="0" type="text" value="a" /></fieldset></form>
EOF

    ok( $result->valid(0) );
    
    ok( ! $result->has_errors(0) );
}
