use Test::More tests => 8;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' );
$w->element( 'Textfield', 'bar' );

$w->constraint( 'AllOrNone', 'foo', 'bar' );

# Valid All
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'yada', bar => 'yada',
    });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="yada" /><input class="textfield" id="widget_bar" name="bar" type="text" value="yada" /></fieldset></form>
EOF
}

# Valid None
{
    my $query = HTMLWidget::TestLib->mock_query({});

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" /><input class="textfield" id="widget_bar" name="bar" type="text" /></fieldset></form>
EOF
}

# Invalid
{
    my $query = HTMLWidget::TestLib->mock_query({ foo => 'yada' });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="yada" /><span class="fields_with_errors"><input class="textfield" id="widget_bar" name="bar" type="text" /></span><span class="error_messages" id="widget_bar_errors"><span class="allornone_errors" id="widget_bar_error_allornone">Invalid Input</span></span></fieldset></form>
EOF
}


# Empty strings - like an empty form as submitted by Firefox
{
	my $query = HTMLWidget::TestLib->mock_query({
		foo => '', bar => ''
	});

	my $f = $w->process($query);
	is_deeply([ ], [$f->errors], "Empty Strings do not count as values"); 
	
	is("$f", <<EOF, 'Output is XML form');
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" /><input class="textfield" id="widget_bar" name="bar" type="text" /></fieldset></form>
EOF
}

# "0" as a query value
{
	my $query = HTMLWidget::TestLib->mock_query({
		foo => 0
	});

	my $f = $w->process($query);
	is_deeply([new HTML::Widget::Error({name => 'bar', type=>'AllOrNone', message=>'Invalid Input'})], [$f->errors],
			'Query parameter of "0" counts as value');

	is("$f", <<EOF, 'Output is XML form with errors');
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" /><span class="fields_with_errors"><input class="textfield" id="widget_bar" name="bar" type="text" /></span><span class="error_messages" id="widget_bar_errors"><span class="allornone_errors" id="widget_bar_error_allornone">Invalid Input</span></span></fieldset></form>
EOF
}
