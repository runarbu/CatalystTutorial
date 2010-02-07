use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'MyApp' }
BEGIN { use_ok 'MyApp::Controller::Login' }

ok( request('/login')->is_success, 'Request should succeed' );
done_testing();
