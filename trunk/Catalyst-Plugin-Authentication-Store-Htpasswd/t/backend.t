#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 19;

use File::Temp qw/tempfile/;

my $m; BEGIN { use_ok($m = "Catalyst::Plugin::Authentication::Store::Htpasswd::Backend") }

(undef, my $tmp) = tempfile();

my $passwd = Authen::Htpasswd->new($tmp);

$passwd->add_user("user", "s3cr3t");

can_ok($m, "new");
isa_ok(my $o = $m->new( $passwd ), $m);

can_ok($m, "file");
isa_ok( $o->file, "Authen::Htpasswd");

can_ok( $m, "user_supports");
ok( $m->user_supports(qw/password self_check/), "user_supports self check" );

can_ok($m, "get_user");
isa_ok( my $u = $o->get_user("user"), "Catalyst::Plugin::Authentication::Store::Htpasswd::User");
isa_ok( $u, "Catalyst::Plugin::Authentication::User");

can_ok( $u, "supports");
ok( $u->supports(qw/password self_check/), "htpasswd users check their own passwords");

can_ok( $u, "check_password");
ok( $u->check_password( "s3cr3t" ), "password is s3cr3t");

ok( $m->user_supports(qw/session/), "user_supports session");

is( $u->store, $o, "can get store");

can_ok( $m, "from_session" );
can_ok( $u, "for_session" );

my $recovered = $u->store->from_session( undef, $u->for_session );

is( $recovered->username, $u->username, "recovery from session works");
