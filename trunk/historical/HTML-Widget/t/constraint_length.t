use Test::More tests => 8;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' );

$w->constraint( 'Length', 'foo' )->min(3)->max(4);

# Valid
{
    my $query = HTMLWidget::TestLib->mock_query({ foo => 'yada' });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="yada" /></fieldset></form>
EOF
}

# Valid (blank)
{
    my $query = HTMLWidget::TestLib->mock_query({ foo => '' });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" /></fieldset></form>
EOF
}

# Invalid
{
    my $query = HTMLWidget::TestLib->mock_query({ foo => 'yadayada' });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><span class="fields_with_errors"><input class="textfield" id="widget_foo" name="foo" type="text" value="yadayada" /></span><span class="error_messages" id="widget_foo_errors"><span class="length_errors" id="widget_foo_error_length">Invalid Input</span></span></fieldset></form>
EOF
}

# Multiple Valid
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => [ 'yada', 'yada', 'yada' ],
    });

    my $f = $w->process($query);
    is( $f->valid('foo'), 1, "Valid" );
    my @results = $f->param('foo');
    is( $results[0], 'yada', "Multiple valid values" );
    is( $results[2], 'yada', "Multiple valid values" );
}

# Multiple Invalid
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => [ 'yada', 'yadayada', 'yadayada' ],
    });

    my $f = $w->process($query);
    is( $f->valid('foo'), 0, "Invalid" );
}
