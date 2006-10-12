
use Test::More tests => 3;
use_ok( Catalyst::Test, 'MiniMojo' );
use_ok('MiniMojo::C::Page');

ok( request('page')->is_success );

