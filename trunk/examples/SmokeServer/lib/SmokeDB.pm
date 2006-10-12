#!/usr/bin/perl

package SmokeDB;

use strict;
use warnings;

use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_classes(qw/Smoke Tag SmokeTags/);

__PACKAGE__;

__END__

=pod

=head1 NAME

SmokeDB - A database for a smoke server

=head1 SYNOPSIS

	use SmokeDB;

=head1 DESCRIPTION

=cut


