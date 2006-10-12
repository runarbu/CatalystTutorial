#!/usr/bin/perl

package SmokeDB::Tag::QueryHelper;

use strict;
use warnings;

sub new {
    my ( $class, $rs ) = @_;
    return bless { rs => $rs }, $class;
}

sub autocomplete {
    my ( $self, $path, %opts ) = @_;
    $self->{rs}->search({ name => { -like => "${path}%" } });
}

sub children {
    my ( $self, $path ) = @_;
    $self->{rs}->search({ name => { -like => "${path}.%" } });
}

__PACKAGE__;

__END__

=pod

=head1 NAME

SmokeDB::Tag::QueryHelper - 

=head1 SYNOPSIS

	use SmokeDB::Tag::QueryHelper;

=head1 DESCRIPTION

=cut


