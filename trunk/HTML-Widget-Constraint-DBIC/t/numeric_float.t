use Test::More tests => 9;

use lib 't/lib';

use_ok( 'HTML::Widget' );
use_ok( 'HTMLWidget::TestLib' );

HTMLWidget::TestLib->fake_column({
    column    => 'foo',
    data_type => 'float',
});

my $widget = HTML::Widget->new;

$widget->constraint( 'DBIC', 'foo' )->class( 'HTMLWidget::TestLib' );

{ # valid
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 0,
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
}

{ # valid
    my $query = HTMLWidget::TestLib->mock_query({
        foo => undef,
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
}

{ # valid
    my $query = HTMLWidget::TestLib->mock_query({
        foo => '',
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
}

{ # valid
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 123.456789,
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
}

{ # valid
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 123,
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
}

{ # invalid string
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'bar',
    });
    
    my $result = $widget->process( $query );
    
    ok( ! $result->valid('foo') );
    
    ok( $result->has_errors( 'foo' ) );
}
