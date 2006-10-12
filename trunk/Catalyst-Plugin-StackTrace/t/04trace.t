#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More;

plan tests => 7;
use Catalyst::Test 'TestApp';

open STDERR, '>/dev/null';

# test that a normal action executes ok
{
    ok( my $res = request('http://localhost/foo/ok'), 'request ok' );
    is( $res->content, 'ok', 'response ok' );
}

# test that a crashed action prints the appropriate debug screen
{
    ok( my $res = request('http://localhost/foo/not_ok'), 'request ok' );
    like( $res->content, qr{Caught exception.+TestApp::Controller::Foo::three}, 'error ok' );
    like( $res->content, qr{Stack Trace}, 'trace ok' );
    like( $res->content, qr{<td>22</td>}, 'line number ok' );
    like( $res->content, qr{<strong class="line">   22:     three()}, 'context ok' );
}

