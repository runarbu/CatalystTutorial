use Test::More tests => 2;
use_ok( Catalyst::Test, 'ServerDB' );

ok( request('/')->is_success );
