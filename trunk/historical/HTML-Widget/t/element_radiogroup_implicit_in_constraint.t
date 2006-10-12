use Test::More tests => 5;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'RadioGroup', 'foo' )->values([ 1, 2 ]);
$w->element( 'RadioGroup', 'bar' )->values([ 3, 4 ]);


# With mocked basic query
{
    my $query = HTMLWidget::TestLib->mock_query({ foo => 1, bar => 1 });

    my $f = $w->process($query);

    ok( $f->valid('foo') );
    ok( ! $f->valid('bar') );
    
    ok( $f->has_errors( 'bar' ) );

    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><span><label for="widget_foo_1" id="widget_foo_1_label"><input checked="checked" class="radio" id="widget_foo_1" name="foo" type="radio" value="1" />1</label><label for="widget_foo_2" id="widget_foo_2_label"><input class="radio" id="widget_foo_2" name="foo" type="radio" value="2" />2</label></span><span><label for="widget_bar_1" id="widget_bar_1_label"><input class="radio" id="widget_bar_1" name="bar" type="radio" value="3" />3</label><label for="widget_bar_2" id="widget_bar_2_label"><input class="radio" id="widget_bar_2" name="bar" type="radio" value="4" />4</label></span><span class="error_messages" id="widget_bar_errors"><span class="in_errors" id="widget_bar_error_in">Invalid Input</span></span></fieldset></form>
EOF
}

