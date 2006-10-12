use Test::More tests => 6;
use utf8;
use lib 't/lib';

use_ok( 'HTML::Widget' );
use_ok( 'HTMLWidget::TestLib' );

HTMLWidget::TestLib->fake_column({
    column    => 'foo',
    data_type => 'varchar',
    size      => 5,
    ignore_trailing_spaces => 1,
});

my $widget = HTML::Widget->new;

$widget->constraint( 'DBIC', 'foo' )->class( 'HTMLWidget::TestLib' );

{ # valid length
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'abcde',
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
}

{ # invalid length
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'abcdef',
    });
    
    my $result = $widget->process( $query );
    
    ok( ! $result->valid('foo') );
    
    ok( $result->has_errors( 'foo' ) );
}

{ # valid length
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'abcde    ',
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
}
