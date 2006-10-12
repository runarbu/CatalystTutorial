package SmokeServer::Model::SmokeDB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

use DateTime;
use DateTime::TimeZone;

use SmokeDB::Tag::QueryHelper;

__PACKAGE__->config(
    schema_class => 'SmokeDB',
    connect_info => [
        'dbi:SQLite:dbname=/www/smoke.woobling.org/SmokeServer/cat_test_smoke.db',
        '', '',
        { AutoCommit => 0 },
        { on_connect_do => [ 'PRAGMA synchronous = OFF' ] },
    ],
);

sub get_tags {
    my ( $self, %params ) = @_;
    
    my @tags;

    unless ( $params{parent} || $params{prefix} ) {
        @tags = ($params{rs} || $self->resultset("Tag"))->all;
    } else {
        my $q = SmokeDB::Tag::QueryHelper->new( $params{rs} || $self->resultset("Tag") );
        if ( $params{prefix} ) {
            @tags = $q->autocomplete( $params{prefix} );
        } elsif( $params{parent} ) {
            @tags = $q->children( $params{parent} );
        } else {
            die "unknown filter for tags";
        }
    }

    @tags = map { $_->name } @tags;

    if ( $params{shallow} ) {
		# this is a weird hack to autocomplete just up to the next dot
        # it should be solved with nested set support in DBIC
        my $num_dots = ( ($params{prefix}||$params{parent}||"") =~ tr/.// );
	$num_dots++ if $params{parent};
        my %seen;
        @tags = grep { !$seen{$_}++ } map { join '.', grep { defined } (split /\./)[0 .. $num_dots] } @tags;
    }

    return \@tags;
}

sub get_smokes {
    my ( $self, %params ) = @_;

    my $id       = $params{id};
    my $tag      = $params{tag};

    my $smoke_rs = $params{rs} || $self->resultset("Smoke");

    if ( $id ) {
        no warnings "uninitialized";
        $id = { -in => $id } if ref $id eq "ARRAY";
        $smoke_rs = $smoke_rs->search({ id => $id });
    }

    if ( $tag ) {
        $smoke_rs = $smoke_rs->search({ "tag.name" => $tag }, { join => { smoke_tags => 'tag' } });
    }

    return $smoke_rs;
}

sub add_smoke {
    my ( $self, $report ) = @_;

    my $model = $report->{model};

    my $smoke;
    $self->schema->txn_do(sub {
        $smoke = $self->resultset("Smoke")->create({
            model => $model,
            date => DateTime->from_epoch(
                epoch => $model->{start_time},
                eval { time_zone => DateTime::TimeZone->new( name => $report->{tz} ) },
            ),
            duration => $model->{end_time} - $model->{start_time},
        });

        $smoke->tag( @{ $report->{tags} } );
    });

    return $smoke;
}

=head1 NAME

SmokeServer::Model::SmokeDB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<SmokeServer>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema
L<SmokeDB>

=head1 AUTHOR

יובל קוג'מן

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
