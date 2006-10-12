#!perl

use strict;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More tests => 10;

use CGI::Catalyst::Test 'TestApp::Response';

{
    my $app = TestApp::Response->new;

    ok( my $response = request( 'http://localhost/response', $app ), 'Request' );
    ok( $response->is_success, 'Response Successful 2xx' );
    is( $response->code, 200, 'Response Code' );

    is( $app->response->body, $response->content, 'CGI::Catalyst::Response->body' );
    is( $app->response->status, $response->code, 'CGI::Catalyst::Response->status' );
    is( $app->response->content_encoding, $response->content_encoding, 'CGI::Catalyst::Response->content_encoding' );
    is( $app->response->content_length, $response->content_length, 'CGI::Catalyst::Response->content_length' );
    is( $app->response->content_type, $response->content_type, 'CGI::Catalyst::Response->content_type' );
    is( $app->response->location, $response->header('Location'), 'CGI::Catalyst::Response->location' );
    is_deeply( $app->response->headers, $response->headers, 'CGI::Catalyst::Response->headers' );
}
