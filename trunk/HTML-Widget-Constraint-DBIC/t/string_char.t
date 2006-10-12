use Test::More tests => 19;
use utf8;
use lib 't/lib';

use_ok( 'HTML::Widget' );
use_ok( 'HTMLWidget::TestLib' );

HTMLWidget::TestLib->fake_column({
    column    => 'foo',
    data_type => 'char',
    size      => 255,
    ignore_trailing_spaces => 1,
});

HTMLWidget::TestLib->fake_column({
    column    => 'bar',
    data_type => 'char',
    size      => 5,
    ignore_trailing_spaces => 1,
});

my $widget = HTML::Widget->new;

$widget->constraint( 'DBIC', 'foo' )->class( 'HTMLWidget::TestLib' );
$widget->constraint( 'DBIC', 'bar' )->class( 'HTMLWidget::TestLib' );

{ # valid
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 0,
        bar => 0,
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
    ok( $result->valid('bar') );
}

{ # valid
    my $query = HTMLWidget::TestLib->mock_query({
        foo => undef,
        bar => undef,
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
    ok( $result->valid('bar') );
}

{ # valid
    my $query = HTMLWidget::TestLib->mock_query({
        foo => '',
        bar => '',
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
    ok( $result->valid('bar') );
}

{ # valid length
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'a' x 255,
        bar => 'abcde',
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
    ok( $result->valid('bar') );
}

{ # invalid foo length
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'a' x 256,
        bar => 'abcde',
    });
    
    my $result = $widget->process( $query );
    
    ok( ! $result->valid('foo') );
    ok( $result->valid('bar') );
    
    ok( $result->has_errors( 'foo' ) );
}

{ # invalid bar length
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'a' x 255,
        bar => 'abcdef',
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
    ok( ! $result->valid('bar') );
    
    ok( $result->has_errors( 'bar' ) );
}

{ # trailing spaces ignored
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'a' x 255 . '   ',
        bar => 'abcde' . '               ',
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
    ok( $result->valid('bar') );
}

{ # valid length
  # a multibyte character should count as 1
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'ç' x 255,
    });
    
    my $result = $widget->process( $query );
    
    ok( $result->valid('foo') );
}
