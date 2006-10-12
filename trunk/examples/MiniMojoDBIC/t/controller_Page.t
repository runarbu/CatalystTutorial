use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'MiniMojoDBIC' }
BEGIN { use_ok 'MiniMojoDBIC::Controller::Page' }

ok( request('/page')->is_success, 'Request should succeed' );


