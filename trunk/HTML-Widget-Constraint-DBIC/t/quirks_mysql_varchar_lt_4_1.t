use Test::More tests => 5;
use utf8;
use lib 't/lib';

use_ok( 'HTML::Widget' );
use_ok( 'HTMLWidget::TestLib' );

HTMLWidget::TestLib->fake_column({
    column    => 'foo',
    data_type => 'varchar',
    size      => 2**16 - 1,
    length_in_bytes => 1,
});

my $widget = HTML::Widget->new;

$widget->constraint( 'DBIC', 'foo' )->class( 'HTMLWidget::TestLib' );

{ # valid length
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'a' x 65_535,
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
}

{ # invalid length
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'ç' x 65_535,
    });
    
    my $result = $widget->process( $query );
    
    ok( ! $result->valid('foo') );
    
    ok( $result->has_errors( 'foo' ) );
}
