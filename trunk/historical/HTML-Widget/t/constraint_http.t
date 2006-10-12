use Test::More tests => 7;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' );

$w->constraint( 'HTTP', 'foo' );

# Valid
{
    my $query = HTMLWidget::TestLib->mock_query({ foo => 'http://oook.de' });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="http://oook.de" /></fieldset></form>
EOF
}

# Invalid
{
    my $query = HTMLWidget::TestLib->mock_query({ foo => 'foobar' });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><span class="fields_with_errors"><input class="textfield" id="widget_foo" name="foo" type="text" value="foobar" /></span><span class="error_messages" id="widget_foo_errors"><span class="http_errors" id="widget_foo_error_http">Invalid Input</span></span></fieldset></form>
EOF
}

# Multiple Valid
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => [ 'http://catalyst.perl.org', 'http://oook.de' ],
    });

    my $f = $w->process($query);
    is( $f->valid('foo'), 1, "Valid" );
    my @results = $f->param('foo');
    is( $results[0], 'http://catalyst.perl.org', "Multiple valid values" );
    is( $results[1], 'http://oook.de',           "Multiple valid values" );
}

# Multiple Invalid
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => [ 'yada', 'foo' ],
    });

    my $f = $w->process($query);
    is( $f->valid('foo'), 0, "Invalid" );
}
