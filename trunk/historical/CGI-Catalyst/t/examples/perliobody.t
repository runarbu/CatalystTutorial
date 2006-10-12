#!perl

use strict;
use warnings;

use Config;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More;

unless ( $Config{useperlio} ) {
    plan skip_all => 'requires a perlio enabled perl';
}

plan tests => 5;

use CGI::Catalyst::Test 'TestApp::Example::PerlIOBody';

{
    my $expected = join '', 'begin', 'default', 'end';

    ok( my $response = request('http://localhost/'), 'Request' );
    ok( $response->is_success, 'Response Successful 2xx' );
    is( $response->code, 200, 'Response Code' );
    is( $response->content, $expected, 'Response Content' );
    is( $response->content_length, length($expected), 'Response Content-Length')
}
