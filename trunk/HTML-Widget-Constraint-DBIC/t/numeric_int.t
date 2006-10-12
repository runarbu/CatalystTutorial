use Test::More tests => 13;

use lib 't/lib';

use_ok( 'HTML::Widget' );
use_ok( 'HTMLWidget::TestLib' );

HTMLWidget::TestLib->fake_column({
    column    => 'foo',
    data_type => 'int',
    size      => 11,
    range_min => - 2**31,
    range_max => 2**31 - 1,
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

{ # valid lower bound
    my $query = HTMLWidget::TestLib->mock_query({
        foo => -2_147_483_648,
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
}

{ # invalid lower bound
    my $query = HTMLWidget::TestLib->mock_query({
        foo => -2_147_483_649,
    });
    
    my $result = $widget->process( $query );
    
    ok( ! $result->valid('foo') );
    
    is_deeply( [$result->has_errors], ['foo'] );
}

{ # valid upper bound
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 2_147_483_647,
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
}

{ # invalid upper bound
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 2_147_483_648,
    });
    
    my $result = $widget->process( $query );
    
    ok( ! $result->valid('foo') );
    
    is_deeply( [$result->has_errors], ['foo'] );
}

{ # invalid string
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'bar',
    });
    
    my $result = $widget->process( $query );
    
    ok( ! $result->valid('foo') );
    
    is_deeply( [$result->has_errors], ['foo'] );
}
