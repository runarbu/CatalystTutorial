use Test::More tests => 3;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w1 = HTML::Widget->new;

$w1->element( 'Textfield', 'foo' );

# Valid
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => ['one', 'two'],
    });

    my $result = $w1->process($query);

    ok( $result->valid( 'foo' ) );
    
    my $params = $result->params;
    
    is_deeply( $params, {foo => ['one','two']} );
}
