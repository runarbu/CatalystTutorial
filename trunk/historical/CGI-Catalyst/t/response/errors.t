#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 3;
use CGI::Catalyst::Test 'TestApp::Response';

{
    ok( my $response = request('http://localhost/response/errors/one'), 'Request' );
    #like( $app->error->[0], qr/^Caught exception "Illegal division by zero/, 'Catalyst Error' );
}

{
    ok( my $response = request('http://localhost/response/errors/two'), 'Request' );
    #like( $app->error->[0], qr/^Couldn't forward to path "\/non\/existing\/path"/, 'Catalyst Error' );
}

{
    ok( my $response = request('http://localhost/response/errors/three'), 'Request' );
    #like( $app->error->[0], qr/^Caught exception "I'm going to die!"$/, 'Catalyst Error' );
}
