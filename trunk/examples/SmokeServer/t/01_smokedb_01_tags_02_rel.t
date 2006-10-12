#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;

use ok "SmokeDB";
use ok "SmokeDB::Tag::QueryHelper";

unlink("test_smoke.db");
isa_ok( my $smokedb = SmokeDB->connect("dbi:SQLite:dbname=test_smoke.db"), "SmokeDB" );
isa_ok( $smokedb, "DBIx::Class::Schema" );
$smokedb->storage->on_connect_do([ "PRAGMA synchronous = OFF" ]);

$smokedb->deploy;

my $tags = $smokedb->resultset("Tag");
my $q = SmokeDB::Tag::QueryHelper->new( $tags );

$smokedb->txn_begin;

my $linux = $tags->create({ name => "platform.linux" });
my $osx = $tags->create({ name => "platform.darwin" });

my $melvin = $tags->create({ name => "platypus.melvin" });

my $moose = $tags->create({ name => "moose" });

my $smokes = $smokedb->resultset("Smoke");
my @smokes = map { $smokes->create({ model => { num => $_ }, date => DateTime->now, duration => 1 }) } 1 .. 10;

$smokedb->txn_commit;

sub rs_is ($$$) {
    my ( $rs, $exp, $desc ) = @_;
    my @exp = sort map { $_->id } @$exp;
    my @rs = sort map { $_->id } $rs->all;
    is_deeply( \@rs, \@exp, $desc );
}

rs_is( $smokes, \@smokes, "all smokes" );
rs_is( $tags->related_resultset("smoke_tags")->related_resultset("smoke"), [ ], "no smokes from tags" );

$smokes[0]->tag( qw/moose platypus.melvin/ );

rs_is( $tags->related_resultset("smoke_tags")->related_resultset("smoke")->search(undef, {group_by => ["smoke.id"]}), [ $smokes[0] ], "smoke from all tags" );
rs_is( $moose->smokes, [ $smokes[0] ], "smoke from moose tag" );


$smokes[1]->tag($linux);
$smokes[2]->tag($osx);

rs_is( $q->autocomplete("platf")->related_resultset("smoke_tags")->related_resultset("smoke"), [ @smokes[1,2] ], "smokes from autocomplete" );
