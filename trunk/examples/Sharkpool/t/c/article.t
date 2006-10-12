
use Test::More tests => 3;
use_ok( Catalyst::Test, 'Sharkpool' );
use_ok('Sharkpool::C::Article');

ok( request('article')->is_success );

