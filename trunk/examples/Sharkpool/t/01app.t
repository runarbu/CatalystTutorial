use Test::More tests => 2;
use_ok( Catalyst::Test, 'Sharkpool' );

ok( request('/')->is_success );

