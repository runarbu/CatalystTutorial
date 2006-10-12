#!perl

use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 10;

use CGI::Catalyst::Test 'TestApp::Request';
use HTTP::Request::Common;

{
    my $parameters = {
        'a' => [ qw(A b C d E f G) ]
    };

    my $query = join( '&', map { 'a=' . $_ } @{ $parameters->{a} } );

    my $request = GET( "http://localhost/?$query" );

    my $app      = TestApp::Request->new;
    my $response = request( $request, $app );

    is( $app->request->method, 'GET', 'CGI::Catalyst::Request method' );
    is_deeply( $app->request->parameters, $parameters, 'CGI::Catalyst::Request parameters' );
}

{
    my $parameters = {
        'a' => [ qw(A b C d E f G) ]
    };

    my $request = POST( 'http://localhost/a/b?a=1&a=2&a=3',
        'Content'      => $parameters,
        'Content-Type' => 'application/x-www-form-urlencoded'
    );

    unshift( @{ $parameters->{a} }, 1, 2, 3 );

    my $app      = TestApp::Request->new;
    my $response = request( $request, $app );

    is( $app->request->method, 'POST', 'CGI::Catalyst::Request method' );
    is( $app->request->content_type, 'application/x-www-form-urlencoded', 'CGI::Catalyst::Request Content-Type' );
    is( $app->request->content_length, $request->content_length, 'CGI::Catalyst::Request Content-Length' );
    is_deeply( $app->request->parameters, $parameters, 'CGI::Catalyst::Request parameters' );
}

{
    my $parameters = {
        'a' => [ qw(A b C d E f G) ]
    };

    my $request = POST( 'http://localhost/a/b?a=1&a=2&a=3',
        'Content'      => [ a => 'A', a => 'b', a => 'C', a => 'd', a => 'E', a => 'f', a => 'G' ],
        'Content-Type' => 'multipart/form-data'
    );

    unshift( @{ $parameters->{a} }, 1, 2, 3 );

    my $app      = TestApp::Request->new;
    my $response = request( $request, $app );

    is( $app->request->method, 'POST', 'CGI::Catalyst::Request method' );
    is( $app->request->content_type, 'multipart/form-data', 'CGI::Catalyst::Request Content-Type' );
    is( $app->request->content_length, $request->content_length, 'CGI::Catalyst::Request Content-Length' );
    is_deeply( $app->request->parameters, $parameters, 'CGI::Catalyst::Request parameters' );
}
