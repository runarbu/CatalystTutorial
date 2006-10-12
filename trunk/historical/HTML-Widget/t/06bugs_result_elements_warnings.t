use Test::More tests => 2 + 1;
use Test::NoWarnings;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

{
    my $w = HTML::Widget->new;

    $w->element( 'Textfield', 'foo' );

    my $query = HTMLWidget::TestLib->mock_query({ foo => 'yada' });

    my $result = $w->process($query);

    my @elements = $result->elements;
    
    ok( @elements == 1 );
}
