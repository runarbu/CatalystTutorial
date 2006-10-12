use Test::More tests => 13;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' );

$w->constraint( 'Integer', 'foo' );

# Valid
{
    my $query = HTMLWidget::TestLib->mock_query({ foo => 23 });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="23" /></fieldset></form>
EOF
}

# Invalid
{
    my $query = HTMLWidget::TestLib->mock_query({ foo => 'yada' });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><span class="fields_with_errors"><input class="textfield" id="widget_foo" name="foo" type="text" value="yada" /></span><span class="error_messages" id="widget_foo_errors"><span class="integer_errors" id="widget_foo_error_integer">Invalid Input</span></span></fieldset></form>
EOF
}

# Multiple Valid
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => [ 123, 321, 111 ],
    });

    my $f = $w->process($query);
    is( $f->valid('foo'), 1, "Valid" );
    my @results = $f->param('foo');
    is( $results[0], 123, "Multiple valid values" );
    is( $results[2], 111, "Multiple valid values" );
}

# Multiple Invalid
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => [ 123, 'foo', 321 ],
    });

    my $f = $w->process($query);
    is( $f->valid('foo'), 0, "Invalid" );
}

{ # undef valid
    my $query = HTMLWidget::TestLib->mock_query({ foo => undef });

    my $f = $w->process($query);
    
    ok( $f->valid('foo') );
}

{ # zero valid
    my $query = HTMLWidget::TestLib->mock_query({ foo => 0 });

    my $f = $w->process($query);
    
    ok( $f->valid('foo') );
}

{ # decimal invalid
    my $query = HTMLWidget::TestLib->mock_query({ foo => '1.1' });

    my $f = $w->process($query);
    
    ok( ! $f->valid('foo') );
    
    is_deeply( [$f->has_errors], ['foo'] );
}

{ # invalid
    my $query = HTMLWidget::TestLib->mock_query({ foo => '10foo' });

    my $f = $w->process($query);
    
    ok( ! $f->valid('foo') );
    
    is_deeply( [$f->has_errors], ['foo'] );
}
