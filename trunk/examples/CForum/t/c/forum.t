
use Test::More tests => 3;
use_ok( Catalyst::Test, 'CForum' );
use_ok('CForum::C::Forum');

ok( request('forum')->is_success );

