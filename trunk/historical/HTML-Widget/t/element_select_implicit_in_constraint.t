use Test::More tests => 5;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Select', 'foo' )->label('Foo')
  ->options( 1 => 'one', 2 => 'two' );
$w->element( 'Select', 'bar' )->label('Bar')
  ->options( 3 => 'three', 4 => 'four' );

# With mocked basic query
{
    my $query = HTMLWidget::TestLib->mock_query({ foo => 1, bar => 1 });

    my $f = $w->process($query);
    
    ok( $f->valid('foo') );
    ok( ! $f->valid('bar') );
    
    ok( $f->has_errors( 'bar' ) );
    
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><label for="widget_foo" id="widget_foo_label">Foo<select class="select" id="widget_foo" name="foo"><option selected="selected" value="1">one</option><option value="2">two</option></select></label><label class="labels_with_errors" for="widget_bar" id="widget_bar_label">Bar<select class="select" id="widget_bar" name="bar"><option value="3">three</option><option value="4">four</option></select></label><span class="error_messages" id="widget_bar_errors"><span class="in_errors" id="widget_bar_error_in">Invalid Input</span></span></fieldset></form>
EOF
}
