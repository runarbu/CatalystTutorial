
use Test::More tests => 3;
use_ok( Catalyst::Test, 'Cataculous' );
use_ok('Cataculous::C::AutoComplete');

ok( request('autocomplete')->is_success );

