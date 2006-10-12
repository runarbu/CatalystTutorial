#!perl

use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 7;

use CGI::Catalyst::Test 'TestApp::Response';
use HTTP::Headers::Util 'split_header_words';

my $expected = {
    CookieA => [ qw( CookieA ValueA path / ) ],
    CookieB => [ qw( CookieB ValueB path / ) ]
};

{
    ok( my $response = request('http://localhost/response/cookies/one'), 'Request' );
    ok( $response->is_success, 'Response Successful 2xx' );

    my $cookies = {};

    for my $cookie ( split_header_words( $response->header('Set-Cookie') ) ) {
        $cookies->{ $cookie->[0] } = $cookie;
    }

    SKIP : {
        skip 'A bug in HTTP::Headers prevents us from testing multiple headers', 1;
        is_deeply( $cookies, $expected, 'Response Cookies' );
    }
}

{
    ok( my $response = request('http://localhost/response/cookies/two'), 'Request' );
    ok( $response->is_redirect, 'Response Redirection 3xx' );
    is( $response->code, 302, 'Response Code' );

    my $cookies = {};

    for my $cookie ( split_header_words( $response->header('Set-Cookie') ) ) {
        $cookies->{ $cookie->[0] } = $cookie;
    }
    
    SKIP : {
        skip 'A bug in HTTP::Headers prevents us from testing multiple headers', 1;
        is_deeply( $cookies, $expected, 'Response Cookies' );
    }
}
