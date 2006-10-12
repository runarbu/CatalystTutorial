#!/usr/bin/perl

package SmokeDB::Smoke;
use base qw/DBIx::Class/;

use strict;
use warnings;

use Storable ();
use DateTime ();
use DateTime::Format::ISO8601 ();
use Time::Duration::Object;
use Test::TAP::Model;

__PACKAGE__->load_components(qw/PK::Auto Core/);

__PACKAGE__->table("smoke");
__PACKAGE__->add_columns(
    id => { data_type => "integer" },
    model => {
        data_type => "blob",
        is_nullable => 0,
    },
    date => { data_type => "datetime" },
    duration => { data_type => "integer" },
);

__PACKAGE__->inflate_column( model => {
    inflate => sub { Test::TAP::Model->new_with_struct( Storable::thaw($_[0]) ) },
    deflate => sub { Storable::nfreeze( eval { $_[0]->structure } || $_[0] ) },
});

__PACKAGE__->inflate_column( date => {
    inflate => sub { DateTime::Format::ISO8601->parse_datetime( shift ) },
    deflate => sub { "$_[0]" },
});

__PACKAGE__->inflate_column( duration => {
    inflate => sub { Time::Duration::Object->new( shift ) },
    deflate => sub { shift->seconds },
});

__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many( smoke_tags => 'SmokeDB::SmokeTags' );
__PACKAGE__->many_to_many( 'tags' => 'smoke_tags', 'tag' );

sub tag {
    my ( $self, @tags ) = @_;

    my $tag_rs = $self->result_source->schema->resultset("Tag");

    foreach my $tag ( @tags ) {
        $tag = $tag_rs->find_or_create({ name => $tag }) unless ref $tag;
        $tag->find_or_create_related(smoke_tags => { smoke => $self->id });
    }
}

sub untag {
    my ( $self, @tags ) = @_;

    my @tag_ids = map { $_->id } grep { ref } @tags;
    my @tag_names = grep { !ref } @tags;

    $self->search_related( smoke_tags => [
        { tag => { -in => \@tag_ids } },
        { "tag.name" => { -in => \@tag_names } },
    ])->delete;
}

sub group {
    my ( $self, $prefix ) = @_;

    my @matching_tags = map { $_->name } $self->tags->search({ name => { -like => "${prefix}.%" } });

    if ( !@matching_tags ) {
        return "... not under $prefix";
    } elsif ( @matching_tags == 1 ) {
        return $matching_tags[0];
    } else {
        return "[ " . join(", ", sort @matching_tags ) . " ]";
    }
}

__PACKAGE__;

__END__

=pod

=head1 NAME

SmokeDB::Smoke - 

=head1 SYNOPSIS

	use SmokeDB::Smoke;

=head1 DESCRIPTION

=cut


