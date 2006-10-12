package Isotope::Engine::FastCGI;

use strict;
use warnings;
use bytes;
use base 'Isotope::Engine::CGI';

use FCGI                qw[];
use Isotope::Exceptions qw[throw_engine];

sub run {
    my ( $self, @arguments ) = @_;

    my $request = FCGI::Request(
         $self->stdin,
         $self->stdout,
         $self->stderr,
         $self->environment, 0, &FCGI::FAIL_ACCEPT_ON_INTR
    );

    while ( $request->Accept >= 0 ) {
        $self->handle( $self->construct_transaction, $request, @arguments );
    }
}

# These methods are overriden here because of a bug in FCGI XS code.
# FCGI ->write returns a unsigned char instead of a int. 
# Will be removed once a patch is made and pushed upstream.

sub send_response_headers {
    my ( $self, $t ) = @_;

    unless ( $t->response->has_header('Status') ) {
        $t->response->header( Status => $t->response->status_line );
    }

    my $headers = $t->response->headers->as_string . "\x0d\x0a";

    my ( $r, $w ) = ( length $headers, 0 );

    $w = $self->stdout->syswrite( $headers, $r );

    unless ( defined $w ) {

        throw_engine message => qq/Could not write response headers to stdout handle./,
                     payload => $!;
    }

    return $r;
}

sub send_response_content_handle {
    my ( $self, $t, $handle ) = @_;

    my ( $buffer, $r, $w, $l, $bufsize ) = ( undef, 0, 0, 0, $self->bufsize );

    while () {

        $r = $handle->sysread( $buffer, $bufsize );

        unless ( defined $r ) {

            next if $! == Errno::EINTR;

            throw_engine message => qq/Could not read from response content handle./,
                         payload => $!;
        }

        last unless $r;

        $w = $self->stdout->syswrite( $buffer, $r );

        unless ( defined $w ) {

            throw_engine message => qq/Could not write response content handle to stdout handle./,
                         payload => $!;
        }

        $l += $r;
    }

    return $l;
}

sub send_response_content_string {
    my ( $self, $t, $string ) = @_;

    my ( $r, $w ) = ( length $$string, 0 );

    $w = $self->stdout->syswrite( $$string, $r );

    unless ( defined $w ) {

        throw_engine message => qq/Could not write response content string to stdout handle./,
                     payload => $!;
    }

    return $r;
}

1;
