#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More tests => 12;
use Catalyst::Test 'TestApp';

BEGIN {
    no warnings 'redefine';

    *Catalyst::Test::local_request = sub {
        my ( $class, $request ) = @_;

        require HTTP::Request::AsCGI;
        my $cgi = HTTP::Request::AsCGI->new( $request, %ENV )->setup;

        $class->handle_request;

        return $cgi->restore->response;
    };
}

run_tests();

sub run_tests {

    # test Lexicon
    {
        my $expected = 'Bonjour';
        my $request  =
          HTTP::Request->new( GET => 'http://localhost:3000/maketext/Hello' );

        $request->header( 'Accept-Language' => 'fr' );

        ok( my $response = request($request), 'Request' );
        ok( $response->is_success, 'Response Successful 2xx' );
        is( $response->code, 200, 'Response Code' );

        is( $response->content, $expected, 'Content OK' );
    }

    # test .po
    {
        my $expected = 'Hallo';
        my $request  =
          HTTP::Request->new( GET => 'http://localhost:3000/maketext/Hello' );

        $request->header( 'Accept-Language' => 'de' );

        ok( my $response = request($request), 'Request' );
        ok( $response->is_success, 'Response Successful 2xx' );
        is( $response->code, 200, 'Response Code' );

        is( $response->content, $expected, 'Content OK' );
    }

    # test language()
    {
        my $expected = 'fr';
        my $request  =
          HTTP::Request->new( GET => 'http://localhost:3000/current_language' );

        $request->header( 'Accept-Language' => 'fr' );

        ok( my $response = request($request), 'Request' );
        ok( $response->is_success, 'Response Successful 2xx' );
        is( $response->code, 200, 'Response Code' );

        is( $response->content, $expected, 'Content OK' );
    }

}
