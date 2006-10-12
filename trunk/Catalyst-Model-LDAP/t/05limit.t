use strict;
use warnings;
use Net::LDAP::Constant qw/LDAP_SIZELIMIT_EXCEEDED/;
use Test::More;

plan skip_all => 'set LDAP_TEST_LIVE to enable this test' unless $ENV{LDAP_TEST_LIVE};
plan tests    => 6;

use FindBin;
use lib "$FindBin::Bin/lib";
use TestApp::Model::LDAP;

my $SIZELIMIT = 2;
my $SN        = 'SMITH';

TestApp::Model::LDAP->config(
    options => {
        sizelimit => $SIZELIMIT,
    },
);

ok(my $ldap = TestApp::Model::LDAP->new, 'created model class');
is($ldap->config->{options}->{sizelimit}, $SIZELIMIT, 'sizelimit configured');

my $mesg = $ldap->search("(sn=$SN)");

is($mesg->code, LDAP_SIZELIMIT_EXCEEDED, 'server response okay');
is($mesg->count, $ldap->config->{options}->{sizelimit}, 'number of entries matches sizelimit');
is($mesg->shift_entry->get_value('sn'), $SN, 'entry sn matches');
is($mesg->shift_entry->sn, $SN, 'entry sn via AUTOLOAD matches');
