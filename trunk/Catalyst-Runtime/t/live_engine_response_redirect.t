#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More tests => 20;
use Catalyst::Test 'TestApp';

{
    ok( my $response = request('http://localhost/engine/response/redirect/one'), 'Request' );
    ok( $response->is_redirect, 'Response Redirection 3xx' );
    is( $response->code, 302, 'Response Code' );
    is( $response->header('X-Catalyst-Action'), 'engine/response/redirect/one', 'Test Action' );
    is( $response->header('Location'), '/test/writing/is/boring', 'Response Header Location' );
}

{
    ok( my $response = request('http://localhost/engine/response/redirect/two'), 'Request' );
    ok( $response->is_redirect, 'Response Redirection 3xx' );
    is( $response->code, 302, 'Response Code' );
    is( $response->header('X-Catalyst-Action'), 'engine/response/redirect/two', 'Test Action' );
    is( $response->header('Location'), 'http://www.google.com/', 'Response Header Location' );
}

{
    ok( my $response = request('http://localhost/engine/response/redirect/three'), 'Request' );
    ok( $response->is_redirect, 'Response Redirection 3xx' );
    is( $response->code, 301, 'Response Code' );
    is( $response->header('X-Catalyst-Action'), 'engine/response/redirect/three', 'Test Action' );
    is( $response->header('Location'), 'http://www.google.com/', 'Response Header Location' );
}

{
    ok( my $response = request('http://localhost/engine/response/redirect/four'), 'Request' );
    ok( $response->is_redirect, 'Response Redirection 3xx' );
    is( $response->code, 307, 'Response Code' );
    is( $response->header('X-Catalyst-Action'), 'engine/response/redirect/four', 'Test Action' );
    is( $response->header('Location'), 'http://www.google.com/', 'Response Header Location' );
}
