use strict;
use warnings;
use Test::More;

plan skip_all => 'set LDAP_TEST_LIVE to enable this test' unless $ENV{LDAP_TEST_LIVE};
plan skip_all => 'set LDAP_BINDDN and LDAP_PASSWORD to enable this test'
    unless $ENV{LDAP_BINDDN} and $ENV{LDAP_PASSWORD};
plan tests    => 7;

use FindBin;
use lib "$FindBin::Bin/lib";
use TestApp::Model::LDAP;

my $UID = 'dwc';

TestApp::Model::LDAP->config(
    dn       => $ENV{LDAP_BINDDN},
    password => $ENV{LDAP_PASSWORD},
);

ok(my $ldap = TestApp::Model::LDAP->new, 'created model class');
is($ldap->config->{dn}, $ENV{LDAP_BINDDN}, 'configured bind DN');
is($ldap->config->{password}, $ENV{LDAP_PASSWORD}, 'configured bind password');

my $mesg = $ldap->search("(uid=$UID)");

ok(! $mesg->is_error, 'server response okay');
is($mesg->count, 1, 'got one entry');
is($mesg->entry(0)->get_value('uid'), $UID, 'entry uid matches');
is($mesg->entry(0)->uid, $UID, 'entry uid via AUTOLOAD matches');
