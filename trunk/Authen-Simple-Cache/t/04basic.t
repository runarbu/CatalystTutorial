#!perl

use strict;
use lib 't/lib';

use Authen::Simple::Cache;
use MyAdapter;
use MyCache;
use MyLog;

use Test::More tests => 8;

my $log = MyLog->new;

my $credentials  = {
    user => 'password'
};

my $decorated = MyAdapter->new(
    credentials => $credentials,
    log         => $log
);

my $decorator = Authen::Simple::Cache->new(
    decorated => $decorated,
    cache     => MyCache->new,
    log       => $log
);

ok( $decorator );
ok( $decorator->authenticate( 'user', 'password' ) );
ok( !$decorator->authenticate( 'john', 'password' ) );

like( $decorator->log->messages->[-2], qr/Caching successful authentication for user 'user'/ );

is_deeply( scalar $decorator->cache->hash, { 'user:password' => 1 } );

$decorator->credentials( {} );

ok( $decorator->authenticate( 'user', 'password' ) );

like( $decorator->log->messages->[-1], qr/Successfully authenticated user 'user' from cache/ );

$decorator->cache->clear;

ok( !$decorator->authenticate( 'user', 'password' ) );
