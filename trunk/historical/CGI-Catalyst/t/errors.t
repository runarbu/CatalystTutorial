#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More tests => 8;
use CGI::Catalyst::Test 'TestApp';

{
    my $app = TestApp->new;
    ok( my $response = request( 'http://localhost/errors/one', $app ), 'Request' );
    like( $app->error->[0], qr/^Caught exception "Illegal division by zero/, 'Catalyst Error' );
}

{
    my $app = TestApp->new;
    ok( my $response = request( 'http://localhost/errors/two', $app ), 'Request' );
    like( $app->error->[0], qr/^Couldn't forward to path "\/non\/existing\/path"/, 'Catalyst Error' );
}

{
    my $app = TestApp->new;
    ok( my $response = request( 'http://localhost/errors/three', $app ), 'Request' );
    like( $app->error->[0], qr/^Caught exception "I'm going to die!"$/, 'Catalyst Error' );
}

{
    my $app = TestApp->new;
    ok( my $response = request( 'http://localhost/non/existing/path', $app ), 'Request' );
    like( $app->error->[0], qr/^Unknown resource "non\/existing\/path"$/, 'Catalyst Error' );
}

