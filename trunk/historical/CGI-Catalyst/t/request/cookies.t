#!perl

use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 10;

use CGI::Catalyst::Test 'TestApp::Request';
use HTTP::Request::Common;

{
    my $request = GET( 'http://localhost/',
        'Cookie' => 'CookieA=ValueA; CookieB=ValueB',
    );

    my $app      = TestApp::Request->new;
    my $response = request( $request, $app );

    isa_ok( $app->request->cookies->{CookieA}, 'CGI::Cookie', 'Cookie CookieA' );
    is( $app->request->cookies->{CookieA}->name, 'CookieA', 'Cookie CookieA name' );
    is( $app->request->cookies->{CookieA}->value, 'ValueA', 'Cookie CookieA value' );

    isa_ok( $app->request->cookies->{CookieB}, 'CGI::Cookie', 'Cookie CookieB' );
    is( $app->request->cookies->{CookieB}->name, 'CookieB', 'Cookie CookieB name' );
    is( $app->request->cookies->{CookieB}->value, 'ValueB', 'Cookie CookieB value' );

    cmp_ok( $app->request->cookie, '==', 2 );
    isa_ok( $app->request->cookie('CookieA'), 'CGI::Cookie', 'Cookie CookieA' );
    isa_ok( $app->request->cookie('CookieB'), 'CGI::Cookie', 'Cookie CookieB' );

    my $cookies = {
        CookieA => $app->request->cookies->{CookieA},
        CookieB => $app->request->cookies->{CookieB}
    };

    is_deeply( $app->request->cookies, $cookies, 'Cookies' );
}
