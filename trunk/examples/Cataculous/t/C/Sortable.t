
use Test::More tests => 3;
use_ok( Catalyst::Test, 'Cataculous' );
use_ok('Cataculous::C::Sortable');

ok( request('sortable')->is_success );

