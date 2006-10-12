use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More tests => 4;

use Catalyst::Test 'TestApp';

{
    my $response;
    ok( $response = request('http://localhost/config/'), 'request ok' );
    is( $response->content, 'foo', 'config ok' );

    $response = request('http://localhost/appconfig/cache');
    ok( $response->content !~ /^__HOME__/, 'home dir substituted in config var' );

    $response = request('http://localhost/appconfig/foo');
    is( $response->content, 'bar', 'app finalize_config works' );
}
