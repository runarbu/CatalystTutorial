#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

my $m; use ok $m = "Catalyst::Plugin::Session::AtomicWrite";

{
    package SomeMock;
    use base $m, qw/Catalyst::Plugin::Session::Store::FastMmap/;
    sub config { {} }
}

my @c = map { bless {}, "SomeMock" } 1 .. 3;
$_->setup_session && $_->setup for @c;

$c[0]->store_session_data("foo", { key => "value", koo => "valey" });

{
    my $c1s = $c[1]->get_session_data("foo");
    my $c2s = $c[2]->get_session_data("foo");

    is_deeply( $c1s, $c2s, "session data loaded by two separate sessions is the same" );

    $c1s->{moose} = "elk";

    $c[1]->store_session_data("foo", $c1s);
    $c[2]->store_session_data("foo", $c2s);

    is_deeply( $c[0]->get_session_data("foo"), $c1s, "session data merged");
}

{
    my ( $c0s, $c1s, $c2s ) = map { $c[$_]->get_session_data("foo") } 0 .. 2;

    is_deeply( $c0s, $c1s );
    is_deeply( $c0s, $c2s );

    $c0s->{koo} = "bloop";
    $c1s->{key} = "moose";
    $c2s->{key} = "elk";

    $c[1]->store_session_data("foo", $c1s);
    $c[0]->store_session_data("foo", $c0s);

    is_deeply( $c[0]->get_session_data("foo"), {
        key => "value", # c0s didn't override it, and kept it from old
        koo => "bloop", # it overridded koo though
        moose => "elk", # unchanged
    });

    $c[2]->store_session_data("foo", $c2s);

    is_deeply( $c[0]->get_session_data("foo"), {
        key => "elk",   # c2s overrided elk
        koo => "valey", # from c2s's old
        moose => "elk", # from c2s's old
    });

    # for this we need three way
    #is_deeply( $c[0]->get_session_data("foo"), {
    #    key => "elk",
    #    koo => "bloop",
    #    moose => "elk",
    #});
}
