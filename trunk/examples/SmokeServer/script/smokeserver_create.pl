#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Pod::Usage;
use Catalyst::Helper;

my $force = 0;
my $mech  = 0;
my $help  = 0;

GetOptions(
    'nonew|force'    => \$force,
    'mech|mechanize' => \$mech,
    'help|?'         => \$help
 );

pod2usage(1) if ( $help || !$ARGV[0] );

my $helper = Catalyst::Helper->new( { '.newfiles' => !$force, mech => $mech } );

pod2usage(1) unless $helper->mk_component( 'SmokeServer', @ARGV );

1;

=head1 NAME

smokeserver_create.pl - Create a new Catalyst Component

=head1 SYNOPSIS

smokeserver_create.pl [options] model|view|controller name [helper] [options]

 Options:
   -force        don't create a .new file where a file to be created exists
   -mechanize    use Test::WWW::Mechanize::Catalyst for tests if available
   -help         display this help and exits

 Examples:
   smokeserver_create.pl controller My::Controller
   smokeserver_create.pl -mechanize controller My::Controller
   smokeserver_create.pl view My::View
   smokeserver_create.pl view MyView TT
   smokeserver_create.pl view TT TT
   smokeserver_create.pl model My::Model
   smokeserver_create.pl model SomeDB DBIC::SchemaLoader dbi:SQLite:/tmp/my.db
   smokeserver_create.pl model AnotherDB DBIC::SchemaLoader dbi:Pg:dbname=foo root 4321

 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro

=head1 DESCRIPTION

Create a new Catalyst Component.

Existing component files are not overwritten.  If any of the component files
to be created already exist the file will be written with a '.new' suffix.
This behavior can be suppressed with the C<-force> option.

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 COPYRIGHT

Copyright 2004 Sebastian Riedel. All rights reserved.

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut