#!/usr/bin/perl

package SmokeDB::Tag;
use base qw/DBIx::Class/;

use SmokeDB::Tag::QueryHelper;

use strict;
use warnings;

use overload '""' => sub { $_[0]->name }, fallback => 1;

__PACKAGE__->load_components(qw/PK::Auto Core/);

__PACKAGE__->table("tag");
__PACKAGE__->add_columns(
    id => { data_type => "integer" },
    name => { data_type => "varchar" },
);
__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many( smoke_tags => 'SmokeDB::SmokeTags' );
__PACKAGE__->many_to_many( 'smokes' => 'smoke_tags', 'smoke' );

__PACKAGE__->add_unique_constraint( name_unique => [qw/name/] );

sub short_name {
    my $self = shift;
    (split '.', $self->name)[-1];
}

sub tokes {
    my $self = shift;
    my $smokes = $self->children->related_resultset("smokes");
    wantarray ? $smokes->all : $smokes;
}

sub children {
    my $self = shift;
    SmokeDB::Tag::QueryHelper->new( $self->result_source->resultset )->children( $self->name );
}


__PACKAGE__;

__END__

=pod

=head1 NAME

SmokeDB::Tag - 

=head1 SYNOPSIS

	use SmokeDB::Tag;

=head1 DESCRIPTION

=cut


