use Test::More tests => 3;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Checkbox', 'foo' )->value('foo')->label('Foo');
$w->element( 'Checkbox', 'bar' )->checked('checked');

$w->constraint( 'Integer', 'foo' );
$w->constraint( 'Integer', 'bar' );

# Without query
{
    my $f = $w->process;
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><label for="widget_foo" id="widget_foo_label"><input class="checkbox" id="widget_foo" name="foo" type="checkbox" value="foo" />Foo</label><input checked="checked" class="checkbox" id="widget_bar" name="bar" type="checkbox" value="1" /></fieldset></form>
EOF
}

# With mocked basic query
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'yada', bar => '23',
    });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><label class="labels_with_errors" for="widget_foo" id="widget_foo_label"><span class="fields_with_errors"><input class="checkbox" id="widget_foo" name="foo" type="checkbox" value="foo" /></span>Foo</label><span class="error_messages" id="widget_foo_errors"><span class="integer_errors" id="widget_foo_error_integer">Invalid Input</span></span><input class="checkbox" id="widget_bar" name="bar" type="checkbox" value="1" /></fieldset></form>
EOF
}
