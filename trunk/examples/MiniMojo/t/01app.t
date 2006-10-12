use Test::More tests => 2;
use_ok( Catalyst::Test, 'MiniMojo' );

ok( request('/')->is_success );
