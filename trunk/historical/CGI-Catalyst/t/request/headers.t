#!perl

use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 5;

use CGI::Catalyst::Test 'TestApp::Request';
use HTTP::Request::Common;

{
    my $request = GET( 'http://localhost/',
        'User-Agent'   => 'MyAgen/1.0',
        'X-Whats-Cool' => 'CGI::Catalyst'
    );

    my $app      = TestApp::Request->new;
    my $response = request( $request, $app );

    isa_ok( $app->request, 'CGI::Catalyst::Request' );
    isa_ok( $app->request->headers, 'HTTP::Headers', 'CGI::Catalyst::Request->headers' );
    is(  $app->request->header('X-Whats-Cool'), $request->header('X-Whats-Cool'), 'CGI::Catalyst::Request->header X-Whats-Cool' );
    is(  $app->request->header('User-Agent'), $request->header('User-Agent'), 'CGI::Catalyst::Request->header User-Agent' );

    my $host = sprintf( '%s:%d', $request->uri->host, $request->uri->port );
    is( $app->request->header('Host'), $host, 'Catalyst::Request->header Host' );
}
