use Test::More tests => 9;
use utf8;
use lib 't/lib';

use_ok( 'HTML::Widget' );
use_ok( 'HTMLWidget::TestLib' );

HTMLWidget::TestLib->fake_column({
    column    => 'foo',
    data_type => 'text',
    size      => 2**16 - 1,
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

{ # valid upper bound
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'a' x 65_535,
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
}

{ # invalid upper bound
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'a' x 65_536,
    });
    
    my $result = $widget->process( $query );
    
    ok( ! $result->valid('foo') );
    
    ok( $result->has_errors( 'foo' ) );
}

{ # valid length
  # a multibyte character should count as 1
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'ç' x 65_535,
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
}