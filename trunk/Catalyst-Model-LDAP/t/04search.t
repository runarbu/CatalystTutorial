use strict;
use warnings;
use Test::More;

plan skip_all => 'set LDAP_TEST_LIVE to enable this test' unless $ENV{LDAP_TEST_LIVE};
plan tests    => 5;

use FindBin;
use lib "$FindBin::Bin/lib";
use TestApp::Model::LDAP;

my $SN = 'TEST';

ok(my $ldap = TestApp::Model::LDAP->new, 'created model class');

my $mesg = $ldap->search("(sn=$SN)");

ok(! $mesg->is_error, 'server response okay');
ok($mesg->entries, 'got entries');
is($mesg->entry(0)->get_value('sn'), $SN, 'first entry sn matches');
is($mesg->entry(0)->sn, $SN, 'first entry sn via AUTOLOAD matches');
