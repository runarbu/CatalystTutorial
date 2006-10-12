#!/opt/local/bin/perl -w

BEGIN { $ENV{CATALYST_ENGINE} ||= 'Test' }

use strict;
use Getopt::Long;
use Pod::Usage;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Cataculous;

my $help = 0;

GetOptions( 'help|?' => \$help );

pod2usage(1) if ( $help || !$ARGV[0] );

print Cataculous->run($ARGV[0])->content . "\n";

1;

=head1 NAME

cataculous_test.pl - Catalyst Test

=head1 SYNOPSIS

cataculous_test.pl [options] uri

 Options:
   -help    display this help and exits

 Examples:
   cataculous_test.pl http://localhost/some_action
   cataculous_test.pl /some_action

 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro

=head1 DESCRIPTION

Run a Catalyst action from the comand line.

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 COPYRIGHT

Copyright 2004 Sebastian Riedel. All rights reserved.

This library is free software. You can redistribute it and/or modify
it under the same terms as perl itself.

=cut
