#!/usr/bin/perl

package SmokeDB::SmokeTags;
use base qw/DBIx::Class/;

use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);

__PACKAGE__->table("smoke_tags");
__PACKAGE__->add_columns(
    smoke => { data_type => "integer" },
    tag => { data_type => "integer" },
);
__PACKAGE__->set_primary_key(qw/smoke tag/);
__PACKAGE__->belongs_to( smoke => "SmokeDB::Smoke" );
__PACKAGE__->belongs_to( tag => "SmokeDB::Tag" );

__PACKAGE__;

__END__

=pod

=head1 NAME

SmokeDB::SmokeTags - 

=head1 SYNOPSIS

	use SmokeDB::SmokeTags;

=head1 DESCRIPTION

=cut


