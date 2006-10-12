use Test::More tests => 7;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' );
$w->element( 'Textfield', 'bar' );

$w->constraint( 'All', 'foo', 'bar' );

# Valid
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'yada', bar => 'yada',
    });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="yada" /><input class="textfield" id="widget_bar" name="bar" type="text" value="yada" /></fieldset></form>
EOF
}

# Invalid
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'yada',
    });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="yada" /><span class="fields_with_errors"><input class="textfield" id="widget_bar" name="bar" type="text" /></span><span class="error_messages" id="widget_bar_errors"><span class="all_errors" id="widget_bar_error_all">Invalid Input</span></span></fieldset></form>
EOF
}

# Empty strings - like an empty form as submitted by Firefox - should be error
{
	my $query = HTMLWidget::TestLib->mock_query({
		foo => '', bar => ''
	});

	my $f = $w->process($query);
	is_deeply([
		new HTML::Widget::Error({ name => 'bar',
		  type => 'All',
		  message => 'Invalid Input'}),
		new HTML::Widget::Error({ name => 'foo',
		  type => 'All',
		  message => 'Invalid Input'}),

	], [$f->errors], "Errors are correct"); 

	is("$f", <<EOF, 'XML output is form with errors')
<form action="/" id="widget" method="post"><fieldset><span class="fields_with_errors"><input class="textfield" id="widget_foo" name="foo" type="text" /></span><span class="error_messages" id="widget_foo_errors"><span class="all_errors" id="widget_foo_error_all">Invalid Input</span></span><span class="fields_with_errors"><input class="textfield" id="widget_bar" name="bar" type="text" /></span><span class="error_messages" id="widget_bar_errors"><span class="all_errors" id="widget_bar_error_all">Invalid Input</span></span></fieldset></form>
EOF
}

# "0" as a query value
{
	my $query = HTMLWidget::TestLib->mock_query({
		foo => 0
	});

	my $f = $w->process($query);
	is_deeply([new HTML::Widget::Error({name => 'bar', type=>'All', message=>'Invalid Input'})], [$f->errors],
			'Query parameter of "0" counts as value');
	is("$f", <<EOF, 'XML output is form with error');
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" /><span class="fields_with_errors"><input class="textfield" id="widget_bar" name="bar" type="text" /></span><span class="error_messages" id="widget_bar_errors"><span class="all_errors" id="widget_bar_error_all">Invalid Input</span></span></fieldset></form>
EOF
}
