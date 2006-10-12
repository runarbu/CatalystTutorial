#!/usr/bin/perl

package SmokeDB::SmokeGrouper;

use strict;
use warnings;

sub new {
    my ( $class, @group_by ) = @_;
    bless \@group_by, $class;
}

sub group {
    my ( $self, $smokes) = @_;
    $smokes = [ $smokes->all ] unless ref $smokes eq "ARRAY";

    $self->_do_group( $self, $smokes );
}

sub _do_group {
    my ( $self, $groups, $smokes ) = @_;

    my ( $group_prefix, @rest ) = @$groups;
    $group_prefix or return { smokes => $smokes };

    my %grouped;
    foreach my $smoke ( @$smokes ) {
        push @{ $grouped{ $smoke->group( $group_prefix ) } ||= [] }, $smoke;
    }

    return { groups => [ map {{
        name => $_,
        %{ $self->_do_group( \@rest, $grouped{$_} ) },
    }} sort keys %grouped ] };
}


__PACKAGE__;

__END__

=pod

=head1 NAME

SmokeDB::SmokeGrouper - 

=head1 SYNOPSIS

	use SmokeDB::SmokeGrouper;

=head1 DESCRIPTION

=cut


