package Isotope::Engine::CGI;

use strict;
use warnings;
use bytes;
use base 'Isotope::Engine::Synchronous';

use Errno               qw[];
use IO::Handle          qw[SEEK_SET];
use Isotope::Exceptions qw[throw_engine];
use Scalar::Util        qw[];
use Moose               qw[has];

has 'bufsize'     => ( isa      => 'Int',
                       is       => 'rw',
                       required => 1,
                       default  => 8192 );

has 'environment' => ( isa      => 'HashRef',
                       is       => 'rw',
                       required => 1,
                       default  => sub { \%ENV } );

has 'stdin'       => ( isa      => 'IO::Handle',
                       is       => 'rw',
                       required => 1,
                       default  => \&default_stdin_handle );

has 'stdout'      => ( isa      => 'IO::Handle',
                       is       => 'rw',
                       required => 1,
                       default  => \&default_stdout_handle );

has 'stderr'      => ( isa      => 'IO::Handle',
                       is       => 'rw',
                       required => 1,
                       default  => \&default_stderr_handle );

sub run {
    my $self = shift;
    return $self->handle( $self->construct_transaction, @_ );
}

sub default_stdin_handle {
    return IO::Handle->new_from_fd( 0, 'r' )
      or throw_engine message => qq/Could not open STDIN in read only mode./,
                      payload => $!;    
}

sub default_stdout_handle {
    return IO::Handle->new_from_fd( 1, 'w' )
      or throw_engine message => qq/Could not open STDOUT in write only mode./,
                      payload => $!;    
}

sub default_stderr_handle {
    return IO::Handle->new_from_fd( 2, 'w' )
      or throw_engine message => qq/Could not open STDERR in write only mode./,
                      payload => $!;    
}

sub read_connection {
    my ( $self, $t ) = @_;

    my $E = $self->environment;

    $t->connection->local_host( $E->{SERVER_NAME} );
    $t->connection->local_ip( $E->{SERVER_ADDR} || $E->{LOCAL_ADDR} );
    $t->connection->local_port( $E->{SERVER_PORT} );
    $t->connection->remote_host( $E->{REMOTE_HOST} );
    $t->connection->remote_ip( $E->{REMOTE_ADDR} );
    $t->connection->remote_port( $E->{REMOTE_PORT} );
    $t->connection->user( $E->{REMOTE_USER} );

    if ( $E->{HTTPS} && uc $E->{HTTPS} eq 'ON' ) {
        $t->connection->secure(1);
    }

    if ( $E->{SERVER_PORT} == 443 ) {
        $t->connection->secure(1);
    }
}

sub read_request_headers {
    my ( $self, $t ) = @_;

    my $E = $self->environment;

    my $uri = URI->new;
    $uri->scheme( $t->connection->secure ? 'https' : 'http' );

    if ( $E->{HTTP_HOST} ) {
        $uri->host_port( $E->{HTTP_HOST} );
    }
    else {
        $uri->host( $E->{SERVER_NAME} );
        $uri->port( $E->{SERVER_PORT} );
    }

    # Fix broken PATH_INFO on Microsoft IIS.
    local $E->{PATH_INFO} = $E->{PATH_INFO};

    if ( $E->{SERVER_SOFTWARE} =~ /^Microsoft-IIS/ && $E->{PATH_INFO} ) {
        $E->{PATH_INFO} =~ s/^\Q$E->{SCRIPT_NAME}\E//;
    }

    if ( $E->{REQUEST_URI} ) {
        $uri->path_query( $E->{REQUEST_URI} );
    }
    else {
        $uri->path( $E->{SCRIPT_NAME} . $E->{PATH_INFO} || '' );
        $uri->query( $E->{QUERY_STRING} ) if $E->{QUERY_STRING};
    }

    $t->request->method( $E->{REQUEST_METHOD} );
    $t->request->protocol( $E->{SERVER_PROTOCOL} );
    $t->request->uri( $uri->canonical );

    my $base = substr( $E->{SCRIPT_NAME}, -1 ) eq '/'
      ? $E->{SCRIPT_NAME}
      : $E->{SCRIPT_NAME} . '/';

    $t->request->base( URI->new_abs( $base, $t->request->uri ) );

    while ( my ( $field, $value ) = each %{ $E } ) {

        next unless $field =~ /^HTTP_|CONTENT_(:?LENGTH|TYPE)/;

        $field =~ s/^HTTP_//;

        $t->request->header( $field => $value );
    }
}

sub read_request_content_handle {
    my ( $self, $t ) = @_;

    my ( $handle, $buffer, $r, $w, $s, $l, $bufsize ) = ( undef, undef, 0, 0, 0, 0, $self->bufsize );

    while () {

        $r = $self->stdin->sysread( $buffer, $bufsize );

        unless ( defined $r ) {

            next if $! == Errno::EINTR;

            throw_engine message => qq/Could not read content from stdin handle./,
                         payload => $!;
        }

        last unless $r;

        unless ( defined $handle ) {
            $handle = $self->construct_content_handle;
        }

        for ( $w = 0; $w < $r; $w += $s || 0 ) {

            $s = $handle->syswrite( $buffer, $r - $w, $w );

            unless ( defined $s ) {

                next if $! == Errno::EINTR;

                throw_engine message => qq/Could not write to content handle./,
                             payload => $!;
            }
        }

        $l += $r;
    }

    if ( defined $handle ) {

        $handle->sysseek( 0, SEEK_SET )
          or throw_engine message => qq/Could not seek content handle./,
                          payload => $!;
    }

    return ( $l, $handle );
}

sub read_request_content_string {
    my ( $self, $t ) = @_;

    my ( $string, $buffer, $offset, $r, $bufsize ) = ( undef, undef, 0, 0, $self->bufsize );

    while () {

        $r = $self->stdin->sysread( $buffer, $bufsize, $offset );

        unless ( defined $r ) {

            next if $! == Errno::EINTR;

            throw_engine message => qq/Could not read content from stdin handle./,
                         payload => $!;
        }

        last unless $r;

        unless ( defined $string ) {
            $string = \$buffer;
        }

        $offset += $r;
    }

    return ( $offset, $string );
}

sub send_response_headers {
    my ( $self, $t ) = @_;

    unless ( $t->response->has_header('Status') ) {
        $t->response->header( Status => $t->response->status_line );
    }

    my $headers = $t->response->headers->as_string . "\x0d\x0a";

    my ( $r, $w, $s ) = ( length $headers, 0, 0 );

    for ( $w = 0; $w < $r; $w += $s || 0 ) {

        $s = $self->stdout->syswrite( $headers, $r - $w, $w );

        unless ( defined $s ) {

            next if $! == Errno::EINTR;

            throw_engine message => qq/Could not write response headers to stdout handle./,
                         payload => $!;
        }
    }

    return $r;
}

sub send_response_content_handle {
    my ( $self, $t, $handle ) = @_;

    my ( $buffer, $r, $w, $s, $l, $bufsize ) = ( undef, 0, 0, 0, 0, $self->bufsize );

    while () {

        $r = $handle->sysread( $buffer, $bufsize );

        unless ( defined $r ) {

            next if $! == Errno::EINTR;

            throw_engine message => qq/Could not read from response content handle./,
                         payload => $!;
        }

        last unless $r;

        for ( $w = 0; $w < $r; $w += $s || 0 ) {

            $s = $self->stdout->syswrite( $buffer, $r - $w, $w );

            unless ( defined $s ) {

                next if $! == Errno::EINTR;

                throw_engine message => qq/Could not write response content handle to stdout handle./,
                             payload => $!;
            }
        }

        $l += $r;
    }

    return $l;
}

sub send_response_content_string {
    my ( $self, $t, $string ) = @_;

    my ( $r, $w, $s ) = ( length $$string, 0, 0 );

    for ( $w = 0; $w < $r; $w += $s || 0 ) {

        $s = $self->stdout->syswrite( $$string, $r - $w, $w );

        unless ( defined $s ) {

            next if $! == Errno::EINTR;

            throw_engine message => qq/Could not write response content string to stdout handle./,
                         payload => $!;
        }
    }

    return $r;
}

1;
