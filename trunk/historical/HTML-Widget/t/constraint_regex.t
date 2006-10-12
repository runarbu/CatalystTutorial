use Test::More tests => 7;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' );

$w->constraint( 'Regex', 'foo' )->regex(qr/^\w+$/);

# Valid
{
    my $query = HTMLWidget::TestLib->mock_query({ foo => 'yada' });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="yada" /></fieldset></form>
EOF
}

# Invalid
{
    my $query = HTMLWidget::TestLib->mock_query({ foo => "yada \n dada" });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><span class="fields_with_errors"><input class="textfield" id="widget_foo" name="foo" type="text" value="yada &#10; dada" /></span><span class="error_messages" id="widget_foo_errors"><span class="regex_errors" id="widget_foo_error_regex">Invalid Input</span></span></fieldset></form>
EOF
}

# Multiple Valid
{
    my $query = HTMLWidget::TestLib->mock_query({ foo => [ 'bar', 'yada' ] });

    my $f = $w->process($query);
    is( $f->valid('foo'), 1, "Valid" );
    my @results = $f->param('foo');
    is( $results[0], 'bar',  "Multiple valid values" );
    is( $results[1], 'yada', "Multiple valid values" );
}

# Multiple Invalid
{
    my $query = HTMLWidget::TestLib->mock_query({ foo => [ 'yada', "\n" ] });

    my $f = $w->process($query);
    is( $f->valid('foo'), 0, "Invalid" );
}
