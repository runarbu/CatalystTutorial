
use Test::More tests => 3;
use_ok( Catalyst::Test, 'Sharkpool' );
use_ok('Sharkpool::C::Static');

ok( request('static')->is_success );

