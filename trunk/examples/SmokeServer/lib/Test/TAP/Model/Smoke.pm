#!/usr/bin/perl

package Test::TAP::Model::Smoke;

use strict;
use warnings;

use Data::Serializer;
use LWP::UserAgent;
use DateTime::TimeZone;

our $VERSION = "0.01_01";

sub new {
    my ( $class, $model, @tags ) = @_;
    my $self = bless {
        model => $model->structure,
        tags => { },
    }, $class;

    $self->add_tags(
        $model->ok ? "passed" : "failed",
        @tags,
    );

    $self;
}

sub serialized {
    my $self = shift;
    $self->serializer->serialize({
        model => $self->{model},
        tags => [ keys %{ $self->{tags} } ],
        tz => eval { DateTime::TimeZone->new( name => "local" )->name  }, # might fail
    });
}

sub serializer {
    my $self = shift;
    $self->{_serializer} ||= Data::Serializer->new( $self->serializer_opts );
}

sub serializer_opts {
    serializer => "Storable",
    compress   => 1,
    encoding   => "b64",
}

sub add_tags {
    my ( $self, @tags ) = @_;
    @{ $self->{tags} }{@tags} = (undef) x @tags;
}

sub lwp {
    my $self = shift;
    $self->{_lwp} ||= do {
        my $ua = LWP::UserAgent->new( );
        $ua->agent( "SmokeServerUploader/$VERSION " );
        $ua;
    };
}

sub upload {
    my ( $self, $uri ) = @_;
    $self->lwp->post( $uri, { smoke_report => $self->serialized } ); 
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Test::TAP::Model::Smoke - 

=head1 SYNOPSIS

	use Test::TAP::Model::Smoke;

=head1 DESCRIPTION

=cut


