
use Test::More tests => 3;
use_ok( Catalyst::Test, 'CForum' );
use_ok('CForum::C::User');

ok( request('user')->is_success );

