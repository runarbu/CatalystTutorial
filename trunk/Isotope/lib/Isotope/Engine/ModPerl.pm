package Isotope::Engine::ModPerl;

use strict;
use warnings;
use bytes;
use base 'Isotope::Engine::Synchronous';

BEGIN {

    unless ( $INC{'mod_perl.pm'} ) {

        my $mod_perl = exists $ENV{MOD_PERL_API_VERSION} && $ENV{MOD_PERL_API_VERSION} >= 2
          ? 'mod_perl2'
          : 'mod_perl';

        eval "require $mod_perl"
          or die qq/Could not load mod_perl. Reason: '$@'./;
    }

    my @import   = qw[DECLINED OK SERVER_ERROR];
    my $constant = { MP10 => 0, MP20 => 0 };

    if ( mod_perl->VERSION >= 1.999022 ) { # mod_perl 2.0.0 RC5

        require Apache2::Access;
        require Apache2::Connection;
        require Apache2::Const;
        require Apache2::Log;
        require Apache2::Module;
        require Apache2::RequestIO;
        require Apache2::RequestRec;
        require Apache2::RequestUtil;
        require Apache2::Response;
        require Apache2::ServerRec;
        require Apache2::ServerUtil;
        require APR::Error;
        require APR::Status;
        require APR::Table;
        require APR::SockAddr;

        $constant->{MP20} = 1;

        Apache2::Const->import(@import);

        *has_module = sub {
            return Apache2::Module::loaded( $_[1] );
        };

        *server = sub {
            return Apache2::ServerUtil->server;
        };
     }
     elsif ( mod_perl->VERSION >= 1.24 && mod_perl->VERSION < 1.99 ) {

         require Apache;
         require Apache::Constants;
         require Apache::File;
         require Apache::Log;
         require Apache::URI;
         require Apache::Table;
         require Socket;

         $constant->{MP10} = 1;

         Apache::Constants->import(@import);

         *has_module = sub {
             return Apache->module( $_[1] );
         };

         *server = sub {
             return Apache->server          if Apache->server;
             return Apache->request->server if Apache->request;
         };
    }
    else {

        my $version = mod_perl->VERSION;
        my $message = qq/Isotope does not work with installed mod_perl version '$version'./;

        if ( $version < 1.24 ) {
            $message .= qq/ mod_perl 1.24 or higher is required.\n/;
        }

        if ( $version > 1.99 ) {
            $message .= qq/ mod_perl 2.0.0 or higher is required.\n/;
        }

        die $message;
    }

    require constant;
    constant->import($constant);
}

use Errno               qw[];
use IO::Handle          qw[SEEK_SET];
use Isotope::Exceptions qw[throw_engine throw_param];
use Scalar::Util        qw[blessed];
use Moose               qw[has];

# HUGE_STRING_LEN / AP_IOBUFSIZE
# 1.3.x/src/include/httpd.h
# 2.2.x/include/httpd.h

has 'bufsize' => ( isa      => 'Int',
                   is       => 'ro',
                   required => 1,
                   default  => 8192 );

sub run {
    my $self = shift;
    $self->handle( $self->construct_transaction, @_ );
    return OK;
}

sub handle_exception {
    my ( $self, $t, $e, $r ) = @_;

    local $@ = $e;

    if ( MP20 && Scalar::Util::blessed($e) && $e->isa('APR::Error') ) {

        if ( APR::Status::is_ECONNRESET($e) ) {
            $t->connection->aborted(1);
        }
        elsif ( APR::Status::is_EOF($e) ) {
            $t->connection->aborted(1);
        }
        elsif ( APR::Status::is_TIMEUP($e) ) {
            $t->connection->aborted(1);
        }

        if ( $t->connection->aborted ) {

            my $remote  = sprintf "%s:%s", $t->connection->remote_ip, $t->connection->remote_port;
            my $message = APR::Error::strerror($e);

            $self->log->debug("Client $remote has aborted connection. Reason: $message.");

            return 0;
        }
    }

    if ( MP10 && Isotope::Exception::Engine->caught && $r->connection->aborted ) {

        $t->connection->aborted(1);

        my $remote  = sprintf "%s:%s", $t->connection->remote_ip, $t->connection->remote_port;
        my $message = $e->has_payload ? $e->payload : 'Unknown';

        $self->log->debug("Client $remote has aborted connection. Reason: $message.");

        return 0;
    }

    return $self->SUPER::handle_exception( $t, $e, $r );
}

sub read_connection {
    my ( $self, $t, $r ) = @_;

    # XXX 2.0.3 has connection->pnotes
    $t->connection->remote_ip( $r->connection->remote_ip );
    $t->connection->remote_host( $r->connection->remote_host );
    $t->connection->user( $r->user );

    if ( MP10 ) {
        my ( $local_port, $local_addr ) = Socket::sockaddr_in( $r->connection->local_addr );
        $t->connection->local_ip( Socket::inet_ntoa($local_addr) );
        $t->connection->local_port( $local_port );
        my ( $remote_port, $remote_addr ) = Socket::sockaddr_in( $r->connection->remote_addr );
        $t->connection->remote_port( $remote_port );
    }

    if ( MP20 ) {
        $t->connection->local_ip( $r->connection->local_ip );
        $t->connection->local_host( $r->connection->local_host );
        $t->connection->local_port( $r->connection->local_addr->port );
        $t->connection->remote_port( $r->connection->remote_addr->port );
        $t->connection->transactions( $r->connection->keepalives );
    }

    my $secure = 0;

    if ( !$secure && MP20 && $INC{'Apache2/ModSSL.pm'} && $r->connection->is_https ) {
        $secure++;
    }

    # this only works if current handler/callback >= PerlResponseHandler
    if ( !$secure && $r->subprocess_env('HTTPS') && lc $r->subprocess_env('HTTPS') eq 'on' ) {
        $secure++;
    }

    $t->connection->secure($secure);
}

sub read_request_headers {
    my ( $self, $t, $r ) = @_;

    my $uri = URI->new;
    $uri->scheme( $t->connection->secure ? 'https' : 'http' );
    $uri->host( $r->get_server_name );
    $uri->port( $r->get_server_port );
    $uri->path_query( MP20 ? $r->unparsed_uri : $r->parsed_uri->unparse );

    $t->request->uri( $uri->canonical );
    $t->request->method( $r->method );
    $t->request->protocol( $r->protocol );

    my $base = '/';

    if ( my $location = $r->location ) {
        ($base) = index( $r->uri, $location ) == 0
          ? $location
          : $r->uri =~ /^(.*?($location))/;
    }

    if ( $r->filename && -f $r->filename && -x _ ) {
        $base = $r->path_info
          ? substr( $r->uri, 0, - length $r->path_info )
          : $r->uri;
    }

    $base .= '/' unless substr( $base, -1 ) eq '/';

    $t->request->base( URI->new_abs( $base, $t->request->uri ) );

    $r->headers_in->do( sub {
        $t->request->headers->add(@_);
        return 1;
    });

    # Neither MP1 or MP2 handles chunked Transfer-Encoding correctly using "emulated" API, $r->read.
    # Until we have switched to native API, tell client that we require Content-Length header.
    # Luckily, chunked requests are still pretty rare :)
    if ( $t->request->has_header('Transfer-Encoding') ) {

        if ( lc $t->request->header('Transfer-Encoding') ne 'identity' ) {

            $r->discard_request_body;

            throw_engine message => 'Length Required',
                         status  => 411;
        }
    }
}

# read_request_content_(handle|string) can be optimized for MP1 and MP2.
# Using bucket brigades on MP2 and get_client_block on MP1.
# MP1 sends a HTTP/1.1 100 Continue on each ->read call for clients
# that sends Expect header, will be solved by using Apaches native API.

sub read_request_content_handle {
    my ( $self, $t, $r ) = @_;

    my $bufsize = $self->bufsize;
    my $length  = $t->request->content_length;

    my ( $handle, $buffer, $read, $w, $s, $offset ) = ( undef, undef, 0, 0, 0, 0 );

    while ( $length ) {

        $read = $r->read( $buffer, $length < $bufsize ? $length : $bufsize );

        unless ( defined $read ) {

            throw_engine message => qq/Could not read request content from client./,
                         payload => $!;
        }

        last unless $read;

        unless ( defined $handle ) {
            $handle = $self->construct_content_handle;
        }

        for ( $w = 0; $w < $read; $w += $s || 0 ) {

            $s = $handle->syswrite( $buffer, $read - $w, $w );

            unless ( defined $s ) {

                next if $! == Errno::EINTR;

                throw_engine message => qq/Could not write to content handle./,
                             payload => $!;
            }
        }

        $length -= $read;
        $offset += $read;
    }

    if ( defined $handle ) {

        $handle->sysseek( 0, SEEK_SET )
          or throw_engine message => qq/Could not seek content handle./,
                          payload => $!;
    }

    return ( $offset, $handle );
}

sub read_request_content_string {
    my ( $self, $t, $r ) = @_;

    my $bufsize = $self->bufsize;
    my $length  = $t->request->content_length;

    my ( $string, $buffer, $offset, $read ) = ( undef, undef, 0, 0 );

    while ( $length ) {

        $read = $r->read( $buffer, $length < $bufsize ? $length : $bufsize, $offset );

        unless ( defined $read ) {

            throw_engine message => qq/Could not read request content from client./,
                         payload => $!;
        }

        last unless $read;

        unless ( defined $string ) {
            $string = \$buffer;
        }

        $length -= $read;
        $offset += $read;
    }

    return ( $offset, $string );
}

sub send_response_headers {
    my ( $self, $t, $r ) = @_;

    $t->response->headers->scan( sub {
        return if $_[0] =~ /^Content-(:?Length|Type)|Set-Cookie$/;
        $r->headers_out->add(@_);
    });

    if ( my @cookies = $t->response->header('Set-Cookie') ) {
        $r->err_headers_out->add( 'Set-Cookie' => $_ ) for @cookies;
    }

    $r->status( $t->response->status );
    $r->status_line( $t->response->status_line );

    if ( my $content_type = $t->response->header('Content-Type') ) {
        $r->content_type($content_type);
    }

    if ( my $content_length = $t->response->content_length ) {
        $r->set_content_length($content_length);
    }

    $r->send_http_header if MP10;

    # http://perl.apache.org/docs/2.0/user/coding/coding.html#Forcing_HTTP_Response_Headers_Out
    $r->rflush if $r->header_only;
}

sub send_response_content_handle {
    my ( $self, $t, $handle, $r ) = @_;

    if ( MP10 && defined $handle->fileno && $handle->fileno > 0 ) {

        my $w = $r->send_fd($handle);

        unless ( defined $w && $w > 0 ) {

            throw_engine message => qq/Could not send response content handle to client./,
                         payload => $!;
        }

        return $w;
    }

    my ( $buffer, $read, $w, $l, $bufsize ) = ( undef, 0, 0, 0, $self->bufsize );

    while () {

        $read = $handle->sysread( $buffer, $bufsize );

        unless ( defined $read ) {

            next if $! == Errno::EINTR;

            throw_engine message => qq/Could not read from response content handle./,
                         payload => $!;
        }

        last unless $read;

        $w = $r->write( $buffer, $read );

        unless ( defined $w ) {

            throw_engine message => qq/Could not write response content handle to client./,
                         payload => $!;
        }

        $l += $w;
    }

    return $l;
}

sub send_response_content_string {
    my ( $self, $t, $string, $r ) = @_;

    my ( $length, $w ) = ( length $$string, 0 );

    $w = $r->write( $$string, $length );

    unless ( defined $w ) {

        throw_engine message => qq/Could not write response content string to client./,
                     payload => $!;
    }

    return $w;
}

1;
