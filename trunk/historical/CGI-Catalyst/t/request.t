#!perl

use strict;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More tests => 32;

use CGI::Catalyst::Test 'TestApp::Request';
use HTTP::Request::Common;

{
    my $request = GET( 'http://localhost:3000/a/b/c/d/e',
        'User-Agent' => 'MyAgen/1.0',
        'Cookie'     => 'CookieA=ValueA',
        'Referer'    => 'http://www.google.com',
    );

    my $app = TestApp::Request->new;

    ok( my $response = request( $request, $app ), 'Request' );
    ok( $response->is_success, 'Response Successful 2xx' );
    is( $response->code, 200, 'Response Code' );

    # headers
    is( $app->request->method, $request->method, 'CGI::Catalyst::Request->method' );

    is( $app->request->user_agent, $request->user_agent, 'CGI::Catalyst::Request->user_agent' );
    is( $app->request->header('User-Agent'), $request->user_agent, 'CGI::Catalyst::Request->header User-Agent' );
    is( $app->request->headers->header('User-Agent'), $request->user_agent, 'CGI::Catalyst::Request->headers->header User-Agent' );

    is( $app->request->referer, $request->referer, 'CGI::Catalyst::Request->referer' );
    is( $app->request->header('Referer'), $request->referer, 'CGI::Catalyst::Request->header Referer' );
    is( $app->request->headers->header('Referer'), $request->referer, 'CGI::Catalyst::Request->headers->header Referer' );

    is( $app->request->content_encoding, undef, 'CGI::Catalyst::Request->content_encoding' );
    is( $app->request->content_length, undef, 'CGI::Catalyst::Request->content_length' );
    is( $app->request->content_type, '', 'CGI::Catalyst::Request->content_type' );

    # cookies
    my $cookies = {
        CookieA => $app->request->cookie('CookieA')
    };

    cmp_ok( $app->request->cookie, '==', 1, 'CGI::Catalyst::Request->cookie' );
    is_deeply( $app->request->cookies, $cookies, 'CGI::Catalyst::Request->cookies' );

    # action
    is( $app->request->action, 'default', 'CGI::Catalyst::Request->action' );
    is_deeply( $app->request->args, [ qw[ a b c d e] ], 'CGI::Catalyst::Request->args' );
    is_deeply( $app->request->arguments, [ qw[ a b c d e] ], 'CGI::Catalyst::Request->arguments' );

    # path
    is( $app->request->base, 'http://localhost:3000/', 'CGI::Catalyst::Request->base' );
    is( $app->request->path, 'a/b/c/d/e', 'CGI::Catalyst::Request->path' );
    is( $app->request->uri, 'http://localhost:3000/a/b/c/d/e', 'CGI::Catalyst::Request->uri' );

    # connection
    is( $app->request->address, '127.0.0.1', 'CGI::Catalyst::Request->address' );
    is( $app->request->hostname, 'localhost', 'CGI::Catalyst::Request->hostname' );
    is( $app->request->protocol, 'HTTP/1.1', 'CGI::Catalyst::Request->protocol' );
    is( $app->request->secure, 0, 'CGI::Catalyst::Request->secure' );
    is( $app->request->user, undef, 'CGI::Catalyst::Request->user' );

    # body
    is( $app->request->body, undef, 'CGI::Catalyst::Request->body' );

    # uploads
    cmp_ok( $app->request->upload, '==', 0, 'CGI::Catalyst::Request->param' );
    is_deeply( $app->request->uploads, { }, 'CGI::Catalyst::Request->params' );

    # parameters
    cmp_ok( $app->request->param, '==', 0, 'CGI::Catalyst::Request->param' );
    is_deeply( $app->request->params, { }, 'CGI::Catalyst::Request->params' );
    is_deeply( $app->request->parameters, { }, 'CGI::Catalyst::Request->parameters' );
}
