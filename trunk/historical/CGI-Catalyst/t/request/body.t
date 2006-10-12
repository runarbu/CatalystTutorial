#!perl

use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 10;

use CGI::Catalyst::Test 'TestApp::Request';
use HTTP::Request::Common;

{
    my $request = POST( 'http://localhost/',
        'Content-Type' => 'text/plain',
        'Content'      => 'Hello Catalyst'
    );

    my $app      = TestApp::Request->new;
    my $response = request( $request, $app );

    isa_ok( $app->request, 'CGI::Catalyst::Request' );
    is( $app->request->method, 'POST', 'CGI::Catalyst::Request method' );
    is( $app->request->content_type, 'text/plain', 'CGI::Catalyst::Request Content-Type' );
    is( $app->request->content_length, $request->content_length, 'CGI::Catalyst::Request Content-Length' );
    is( $app->request->body, $request->content, 'CGI::Catalyst::Request Content' );
}

{
    my $request = POST( 'http://localhost/',
        'Content-Type' => 'text/plain',
        'Content'      => 'x' x 100_000
    );

    my $app      = TestApp::Request->new;
    my $response = request( $request, $app );

    isa_ok( $app->request, 'CGI::Catalyst::Request' );
    is( $app->request->method, 'POST', 'CGI::Catalyst::Request method' );
    is( $app->request->content_type, 'text/plain', 'CGI::Catalyst::Request Content-Type' );
    is( $app->request->content_length, $request->content_length, 'CGI::Catalyst::Request Content-Length' );
    is( $app->request->body, $request->content, 'CGI::Catalyst::Request Content' );
}
