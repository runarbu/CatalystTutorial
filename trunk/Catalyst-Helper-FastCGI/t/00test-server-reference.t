#!/usr/bin/perl
use warnings;
use strict;

=head1 NOTES

This tests the fcgi test application with the built in server -
i.e. these tests privide the reference behaviour.  If you get failing
tests here something is wrong with your installation of catalyst or
with the test application.

=cut

use Test::More;
use FindBin qw($Bin);
use lib "$Bin/lib/FcgiTest/lib";

use Test::WWW::Mechanize::Catalyst 'FcgiTest';
my $server = 'http://localhost';
my $ua = Test::WWW::Mechanize::Catalyst->new;

require "$Bin/run/01-behaviour-tests.tl";
run_tests($server, $ua);
