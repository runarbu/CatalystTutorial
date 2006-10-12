#!perl

use strict;
use warnings;
use FindBin;
use Test::More;

use lib "$FindBin::Bin/lib";

BEGIN {
    eval { require DBD::SQLite }
        or plan skip_all => "DBD::SQLite is required for this test";

    eval { require Catalyst::Plugin::Session::State::Cookie }
        or plan skip_all => "Catalyst::Plugin::Session::State::Cookie is required for this test";

    eval { require Test::WWW::Mechanize::Catalyst }
        or plan skip_all => "Test::WWW::Mechanize::Catalyst is required for this test";

    eval { require Catalyst::Model::DBIC::Schema }
        or plan skip_all => "Catalyst::Model::DBIC::Schema is required for this test";

    plan tests => 12;

    $ENV{TESTAPP_DB_FILE} = "$FindBin::Bin/session.db";

    $ENV{TESTAPP_CONFIG} = {
        name    => 'TestApp',
        session => {
            dbic_class => 'DBICSchema::Session',
            data_field => 'data',
        },
    };

    $ENV{TESTAPP_PLUGINS} = [qw/
        Session
        Session::State::Cookie
        Session::Store::DBIC
    /];
}

use SetupDB;
use Test::WWW::Mechanize::Catalyst 'TestApp';

my $mech = Test::WWW::Mechanize::Catalyst->new;

my $key   = 'schema';
my $value = scalar localtime;

# Setup session
$mech->get_ok("http://localhost/session/setup?key=$key&value=$value", 'request to set session value');
$mech->content_is('ok', 'set session value');

# Setup flash
$mech->get_ok("http://localhost/flash/setup?key=$key&value=$value", 'request to set flash value');
$mech->content_is('ok', 'set session value');

# Check flash
$mech->get_ok("http://localhost/flash/output?key=$key", 'request to get flash value');
$mech->content_is($value, 'got session value back');

# Check session
$mech->get_ok("http://localhost/session/output?key=$key", 'request to get session value');
$mech->content_is($value, 'got session value back');

# Delete session
$mech->get_ok('http://localhost/session/delete', 'request to delete session');
$mech->content_is('ok', 'deleted session');

# Delete expired sessions
$mech->get_ok('http://localhost/session/delete_expired', 'request to delete expired sessions');
$mech->content_is('ok', 'deleted expired sessions');

# Clean up
unlink $ENV{TESTAPP_DB_FILE};
