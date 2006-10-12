#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More;

BEGIN {
    
    eval "require CGI::Session";

    if ( $@ ) {
        plan skip_all => 'requires CGI::Session';
    }
}

plan tests => 8;

use CGI::Catalyst::Test 'TestApp::Example::CGISession';
use HTTP::Request::Common;

sub session {
    my $id      = shift;
    my $dsn     = TestApp::Example::CGISession::SESSION_DSN;
    my $options = TestApp::Example::CGISession::SESSION_OPTIONS;

    return CGI::Session->new( $dsn, $id, $options );
}

{
    my $session;

    {
        $session = session();
        $session->param( test => 'new' );
        $session = $session->id;
    }

    my $request = GET( 'http://localhost/',
        'Cookie' => "session=$session",
    );

    ok( my $response = request($request), 'Request' );
    ok( $response->is_success, 'Response Successful 2xx' );
    is( $response->code, 200, 'Response Code' );
    is( $response->content, 'new', 'Response Content' );
}

{
    ok( my $response = request('http://localhost/'), 'Request' );
    ok( $response->is_success, 'Response Successful 2xx' );
    is( $response->code, 200, 'Response Code' );
    is( $response->content, 'created', 'Response Content' );
}
