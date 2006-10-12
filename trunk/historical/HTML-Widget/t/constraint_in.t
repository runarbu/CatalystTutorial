#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 8;


my $m; BEGIN { use_ok($m = "HTML::Widget::Constraint::In") }

can_ok($m, "new");
isa_ok(my $o = $m->new, $m);

can_ok($m, "in");
$o->in( qw/foo bar gorch/ );

can_ok($m, "validate");

ok( $o->validate( "foo" ), "foo");
ok( $o->validate( "bar" ), "bar");
ok( !$o->validate( "baz" ), "baz");

