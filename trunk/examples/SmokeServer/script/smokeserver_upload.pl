#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use Test::TAP::Model;
use Test::TAP::Model::Smoke;

my $uri = shift;

my $model = Test::TAP::Model->new_with_tests( @ARGV );
my $report = Test::TAP::Model::Smoke->new( $model, qw/milk elk tag1/);

exit $report->upload($uri)->code == 200 ? 0 : 1;
