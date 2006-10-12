#!/usr/local/bin/perl -w

use strict;
use Getopt::Long;
use Pod::Usage;
use Catalyst::Helper;

my $help = 0;
my $nonew = 0;

GetOptions( 'help|?' => \$help,
	    'nonew'  => \$nonew );

pod2usage(1) if ( $help || !$ARGV[0] );

my $helper = Catalyst::Helper->new({'.newfiles' => !$nonew});
pod2usage(1) unless $helper->mk_component( 'BookDB', @ARGV );

1;

=head1 NAME

bookdb_create.pl - Create a new Catalyst Component

=head1 SYNOPSIS

bookdb_create.pl [options] model|view|controller name [helper] [options]

 Options:
   -help    display this help and exits
   -nonew   don't create a .new file where a file to be created exists

 Examples:
   bookdb_create.pl controller My::Controller
   bookdb_create.pl view My::View
   bookdb_create.pl view MyView TT
   bookdb_create.pl view TT TT
   bookdb_create.pl model My::Model
   bookdb_create.pl model SomeDB CDBI dbi:SQLite:/tmp/my.db
   bookdb_create.pl model AnotherDB CDBI dbi:Pg:dbname=foo root 4321

 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro

=head1 DESCRIPTION

Create a new Catalyst Component.

Existing component files are not overwritten.  If any of the component files
to be created already exist the file will be written with a '.new' suffix.
This behaviour can be supressed with the C<-nonew> option.

=head1 AUTHOR

Sebastian Riedel, C<sri\@oook.de>

=head1 COPYRIGHT

Copyright 2004 Sebastian Riedel. All rights reserved.

This library is free software. You can redistribute it and/or modify
it under the same terms as perl itself.

=cut
