#!/usr/bin/perl -w

BEGIN { 
    $ENV{CATALYST_ENGINE} ||= 'HTTP';
    $ENV{CATALYST_SCRIPT_GEN} = 6;
}  

use strict;
use Getopt::Long;
use Pod::Usage;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Streaming;

my $fork = 0;
my $help = 0;
my $host = undef;
my $port = 3000;

GetOptions(
    'fork'   => \$fork,
    'help|?' => \$help,
    'host=s' => \$host,
    'port=s' => \$port
);

pod2usage(1) if $help;

Streaming->run( $port, $host, $fork );

1;

=head1 NAME

streaming_server.pl - Catalyst Testserver

=head1 SYNOPSIS

streaming_server.pl [options]

 Options:
   -f -fork    handle each request in a new process
   -? -help    display this help and exits
      -host    host (defaults to all)
   -p -port    port (defaults to 3000)

 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro

=head1 DESCRIPTION

Run a Catalyst Testserver for this application.

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 COPYRIGHT

Copyright 2004 Sebastian Riedel. All rights reserved.

This library is free software. You can redistribute it and/or modify
it under the same terms as perl itself.

=cut
