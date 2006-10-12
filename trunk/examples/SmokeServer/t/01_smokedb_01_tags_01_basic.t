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

my $linux = $tags->find_or_create({ name => "platform.linux" });
my $osx = $tags->find_or_create({ name => "platform.darwin" });

my $melvin = $tags->find_or_create({ name => "platypus.melvin" });

my $moose = $tags->find_or_create({ name => "moose" });

my $three_level1 = $tags->find_or_create({ name => "one.two.three" });
my $three_level2 = $tags->find_or_create({ name => "one.two.four" });
my $three_level3 = $tags->find_or_create({ name => "one.five.three" });

sub rs_is ($$$) {
    my ( $rs, $exp, $desc ) = @_;
    my @exp = sort map { $_->id } @$exp;
    my @rs = sort map { $_->id } $rs->all;
    is_deeply( \@rs, \@exp, $desc );
}

rs_is( $tags, [ $linux, $osx, $melvin, $moose, $three_level1, $three_level2, $three_level3 ], "all tags" );
rs_is( $q->autocomplete("plat"), [ $linux, $osx, $melvin ], "autocomplete" );
rs_is( $q->autocomplete("platform"), [ $linux, $osx ], "autocomplete" );
rs_is( $q->children("platform"), [ $linux, $osx ], "children" );
rs_is( $q->children("plat"), [], "children" );
rs_is( $q->children("one"), [ $three_level1, $three_level2, $three_level3 ], "children");
rs_is( $q->children("one.two"), [ $three_level1, $three_level2 ], "children");
rs_is( $q->autocomplete("one"), [ $three_level1, $three_level2, $three_level3 ], "autocomplete");
rs_is( $q->autocomplete("one."), [ $three_level1, $three_level2, $three_level3 ], "autocomplete");

