use Test::More tests => 3;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

 my $w = HTML::Widget->new;
#     my $e = $widget->element( 'RadioGroup', 'name' ['foo', 'bar', 'baz'] );
#     $e->comment('(Required)');
#     $e->label('Foo');
#     $e->value('bar');

$w->element( 'RadioGroup', 'bar' )->values([ 'opt1', 'opt2', 'opt3'])->value('opt1');

# Without query
{
    my $f = $w->process;
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><span><label for="widget_bar_1" id="widget_bar_1_label"><input checked="checked" class="radio" id="widget_bar_1" name="bar" type="radio" value="opt1" />Opt1</label><label for="widget_bar_2" id="widget_bar_2_label"><input class="radio" id="widget_bar_2" name="bar" type="radio" value="opt2" />Opt2</label><label for="widget_bar_3" id="widget_bar_3_label"><input class="radio" id="widget_bar_3" name="bar" type="radio" value="opt3" />Opt3</label></span></fieldset></form>
EOF
}

# With mocked basic query
{
    my $query = HTMLWidget::TestLib->mock_query({ bar => 'opt2' });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><span><label for="widget_bar_1" id="widget_bar_1_label"><input class="radio" id="widget_bar_1" name="bar" type="radio" value="opt1" />Opt1</label><label for="widget_bar_2" id="widget_bar_2_label"><input checked="checked" class="radio" id="widget_bar_2" name="bar" type="radio" value="opt2" />Opt2</label><label for="widget_bar_3" id="widget_bar_3_label"><input class="radio" id="widget_bar_3" name="bar" type="radio" value="opt3" />Opt3</label></span></fieldset></form>
EOF
}

