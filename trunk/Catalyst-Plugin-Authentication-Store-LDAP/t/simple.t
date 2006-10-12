#!/usr/bin/perl

use strict;
use warnings;
use Catalyst::Exception;

use Test::More tests => 4;

BEGIN { use_ok("Catalyst::Plugin::Authentication::Store::LDAP::Backend") }

my $back = Catalyst::Plugin::Authentication::Store::LDAP::Backend->new({
            'ldap_server' => 'ldap.openldap.org',
            'binddn' => 'anonymous',
            'bindpw' => 'dontcarehow',
            'start_tls' => 0,
            'user_basedn' => 'ou=People,dc=OpenLDAP,dc=Org',
            'user_filter' => '(&(objectClass=person)(uid=%s))',
            'user_scope' => 'one',
            'user_field' => 'uid',
            'use_roles' => 0,
    });
isa_ok($back, "Catalyst::Plugin::Authentication::Store::LDAP::Backend");
my $user = $back->get_user('kurt');
isa_ok($user, "Catalyst::Plugin::Authentication::Store::LDAP::User");
my $displayname = $user->displayname;
cmp_ok($displayname, 'eq', 'Kurt Zeilenga', 'Should be Kurt Zeilenga');

