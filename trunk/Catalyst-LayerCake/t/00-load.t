#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Catalyst::LayerCake' );
}

diag( "Testing Catalyst::LayerCake $Catalyst::LayerCake::VERSION, Perl $], $^X" );
