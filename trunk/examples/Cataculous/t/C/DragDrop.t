
use Test::More tests => 3;
use_ok( Catalyst::Test, 'Cataculous' );
use_ok('Cataculous::C::DragDrop');

ok( request('dragdrop')->is_success );

