package Isotope::Engine;

use strict;
use warnings;
use bytes;
use base 'Isotope::Object';

use prefork 'File::Temp';
use prefork 'IO::Seekable';

use File::Spec          qw[];
use Isotope::Exceptions qw[throw_engine];
use Moose               qw[has];

has 'application' => ( isa       => 'Isotope::Application',
                       is        => 'rw',
                       weak_ref  => 1,
                       trigger   => sub {
                           my ( $self, $application ) = @_;

                           unless ( $self->has_log ) {
                               $self->log( $application->construct_log($self) );
                           }
                       });

has 'log'         => ( isa       => 'Object',
                       is        => 'rw',
                       predicate => 'has_log' );

has 'content_as'  => ( isa       => 'Str',
                       is        => 'ro',
                       default   => 'string',
                       required  => 1 );

has 'tempdir'     => ( isa       => 'Str',
                       is        => 'rw',
                       required  => 1,
                       default   => sub { File::Spec->tmpdir } );

sub BUILD {
    my ( $self, $params ) = @_;

    my $tempdir = $self->tempdir;

    unless ( File::Spec->file_name_is_absolute($tempdir) ) {
        $tempdir = File::Spec->rel2abs($tempdir);
    }

    throw_engine message => qq/Tempdir path '$tempdir' does not exist./,
                 payload => $!
      unless -e $tempdir;

    throw_engine message => qq/Tempdir path '$tempdir' is not a directory./,
                 payload => $!
      unless -d _;

    throw_engine message => qq/Tempdir path '$tempdir' is not writable by effective uid '$>'./,
                 payload => $!
      unless -w _;

    $self->tempdir($tempdir);
}

sub construct_connection {
    return shift->application->construct_connection(@_);
}

sub construct_request {
    return shift->application->construct_request(@_);
}

sub construct_response {
    return shift->application->construct_response(@_);
}

sub construct_transaction {
    my ( $self, %params ) = @_;

    $params{connection} ||= $self->construct_connection;
    $params{request}    ||= $self->construct_request;
    $params{response}   ||= $self->construct_response;

    return $self->application->construct_transaction(%params);
}

sub construct_content_handle {
    my $self = shift;

    require File::Temp;
    require IO::Seekable;

    # This is a bit hackish, but File::Temp is a IO::Seekable.
    # XXX push a patch upstream.
    unless ( File::Temp->isa('IO::Seekable') ) {
        push @File::Temp::ISA, 'IO::Seekable';
    }

    my $handle = File::Temp->new( dir => $self->tempdir )
      or throw_engine message => qq/Could not create a temporary content handle./,
                      payload => $!;

    binmode( $handle )
      or throw_engine message => qq/Could not bimode temporary content handle./,
                      payload => $!;
                      
    return $handle;
}

sub handle_exception {
    return shift->application->handle_exception(@_);
}

sub handle_transaction {
    my ( $self, $t, @arguments ) = @_;

    eval {
        $self->application->handle_transaction( $t, @arguments );
    };

    if ( my $e = $@ ) {
        $self->handle_exception( $t, $e, @arguments );
    }
}

sub setup { 1 }

1;
