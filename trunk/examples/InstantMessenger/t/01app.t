use Test::More tests => 2;
BEGIN { use_ok( Catalyst::Test, 'IM' ); }

ok( request('/')->is_success );
