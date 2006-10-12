use Test::More tests => 2;
use_ok( Catalyst::Test, 'CForum' );

ok( request('/')->is_success );
