use strict;
use warnings;
use Test::More 'no_plan';

use Test::TAP::Model;
use Test::TAP::Model::Smoke;

use DateTime;

use ok "Test::WWW::Mechanize::Catalyst" => "SmokeServer";

unlink("cat_test_smoke.db");
my $smokedb = SmokeServer->model("SmokeDB")->schema;

$smokedb->deploy;

my $model = Test::TAP::Model->new_with_struct({
    test_files => [
        {
            file    => "t/one.t",
            results => { },
            events  => [
                type   => "test",
                num    => 1,
                ok     => 1,
                result => "foo",
                todo   => 0,
                line   => 2,
            ],
        },
    ],
    start_time => time() - 123,
    end_time => time(),
});

my $mech = Test::WWW::Mechanize::Catalyst->new;

{
    package MySmoke;
    use base qw/Test::TAP::Model::Smoke/;
    sub lwp { $mech }
}

my $smoke_report = MySmoke->new( $model, "platform.$^O", "perl.$]" );

my $res = $smoke_report->upload( "http://localhost/submit" );

is( $res->code, 200, "upload succeeded" );

my $smokes = $smokedb->resultset("Smoke");

is( $smokes->count, 1, "one smoke in the db" );

my ( $smoke ) = ( $smokes->all );

is( $smoke->date, DateTime->from_epoch( epoch => $model->structure->{start_time}, time_zone => "local" ), "start_time is correct" );
isa_ok( $smoke->model, "Test::TAP::Model", "model" );

