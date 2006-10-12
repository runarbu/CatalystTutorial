use Test::More tests => 2;
use_ok( Catalyst::Test, 'Cataculous' );

ok( request('/')->is_success );
