#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More;
use File::Path;

BEGIN {
    eval "use Catalyst::Plugin::Cache::FileCache";
    plan $@
        ? ( skip_all => 'needs Catalyst::Plugin::Cache::FileCache for testing' )
        : ( tests => 18 );
}

# remove previous cache
rmtree 't/var' if -d 't/var';

use Catalyst::Test 'TestApp';

# cache a page
ok( my $res = request('http://localhost/cache/count'), 'request ok' );
is( $res->content, 1, 'count is 1' );

# page will be served from cache
ok( $res = request('http://localhost/cache/count'), 'request ok' );
is( $res->content, 1, 'count is still 1 from cache' );

# clear the cached page
ok( $res = request('http://localhost/cache/clear_cache'), 'request ok' );

# request again
ok( $res = request('http://localhost/cache/count'), 'request ok' );
is( $res->content, 3, 'count after clear_cache is 3' );

# page will be served from cache
ok( $res = request('http://localhost/cache/count'), 'request ok' );
is( $res->content, 3, 'count is still 3 from cache' );

# clear the cached page with the regex format
ok( $res = request('http://localhost/cache/clear_cache_regex'), 'request ok' );

# request again
ok( $res = request('http://localhost/cache/count'), 'request ok' );
is( $res->content, 5, 'count after clear_cache_regex is 5' );

# test caching with expiration time
ok( $res = request('http://localhost/cache/count/2'), 'request ok' );
is( $res->content, 6, 'count after expiration test is 6' );

# first request should come from cache
ok( $res = request('http://localhost/cache/count/2'), 'request ok' );
is( $res->content, 6, 'count is still 6' );

# wait...
sleep 3;

# cache should have expired
ok( $res = request('http://localhost/cache/count/2'), 'request ok' );
is( $res->content, 7, 'count after cache expired is 7' );
