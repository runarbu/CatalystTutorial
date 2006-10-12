#!perl

use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 6;

use CGI::Catalyst::Test 'TestApp::Response';

{
    my $expected = join( ', ', 1 .. 10 );

    ok( my $response = request('http://localhost/response/headers/one'), 'Request' );    
    ok( $response->is_success, 'Response Successful 2xx' );
    is( $response->code, 200, 'Response Code' );
    is( $response->header('X-Header-A'), 'A', 'Response Header X-Header-A' );
    is( $response->header('X-Header-B'), 'B', 'Response Header X-Header-B' );

    SKIP : {
        skip 'A bug in HTTP::Headers prevents us from testing multiple headers', 1;
        is( $response->header('X-Header-Numbers'), $expected, 'Response Header X-Header-Numbers' );
    }
}
