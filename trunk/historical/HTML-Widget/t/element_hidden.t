use Test::More tests => 3;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Hidden', 'foo' )->value('foo');
$w->element( 'Hidden', 'bar' );

$w->constraint( 'Integer', 'foo' );
$w->constraint( 'Integer', 'bar' );

# Without query
{
    my $f = $w->process;
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="hidden" id="widget_foo" name="foo" type="hidden" value="foo" /><input class="hidden" id="widget_bar" name="bar" type="hidden" value="1" /></fieldset></form>
EOF
}

# With mocked basic query
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'yada', bar => '23',
    });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="hidden" id="widget_foo" name="foo" type="hidden" value="yada" /><input class="hidden" id="widget_bar" name="bar" type="hidden" value="23" /></fieldset></form>
EOF
}
