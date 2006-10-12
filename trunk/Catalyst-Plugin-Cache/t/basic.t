#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;

use ok "Catalyst::Plugin::Cache";

use Catalyst::Plugin::Cache::Backend::Memory;

{
    package MockApp;
    use base qw/Catalyst::Plugin::Cache/;
    
    sub registered_plugins {}

    my %config;
    sub config { \%config };
}

MockApp->setup;
my $c = bless {}, "MockApp";

can_ok( $c, "register_cache_backend" );
can_ok( $c, "unregister_cache_backend" );

MockApp->register_cache_backend( default => Catalyst::Plugin::Cache::Backend::Memory->new );
MockApp->register_cache_backend( moose => Catalyst::Plugin::Cache::Backend::Memory->new );

can_ok( $c, "cache" );

ok( $c->cache, "->cache returns a value" );

can_ok( $c->cache, "get" ); #, "rv from cache" );
can_ok( $c->cache("default"), "get" ); #, "default backend" );
can_ok( $c->cache("moose"), "get" ); #, "moose backend" );

ok( !$c->cache("lalalala"), "no lalala backend");

MockApp->unregister_cache_backend( "moose" );

ok( !$c->cache("moose"), "moose backend unregistered");


dies_ok {
    MockApp->register_cache_backend( ding => undef );
} "can't register invalid backend";

dies_ok {
    MockApp->register_cache_backend( ding => bless {}, "SomeClass" );
} "can't register invalid backend";



can_ok( $c, "default_cache_backend" );

can_ok( $c, "choose_cache_backend_wrapper" );
can_ok( $c, "choose_cache_backend" );

can_ok( $c, "cache_set" );
can_ok( $c, "cache_get" );
can_ok( $c, "cache_remove" );

$c->cache_set( foo => "bar" );
is( $c->cache_get("foo"), "bar", "set" );

$c->cache_remove( "foo" );
is( $c->cache_get("foo"), undef, "remove" );

MockApp->register_cache_backend( elk => Catalyst::Plugin::Cache::Backend::Memory->new );

is( $c->choose_cache_backend_wrapper( key => "foo" ), $c->default_cache_backend, "choose default" );
is( $c->choose_cache_backend_wrapper( key => "foo", backend => "elk" ), $c->get_cache_backend("elk"), "override choice" );


$c->cache_set( foo => "gorch", backend => "elk" );
is( $c->cache_get("foo"), undef, "set to custom backend (get from non custom)" );
is( $c->cache_get("foo", backend => "elk"), "gorch", "set to custom backend (get from custom)" );

my $cache_elk = $c->cache( backend => "elk" );
my $cache_norm = $c->cache();

is( $cache_norm->get("foo"), undef, "default curried cache has no foo");
is( $cache_elk->get("foo"), "gorch", "curried custom backend has foo" );
