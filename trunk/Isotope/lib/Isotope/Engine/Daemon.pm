package Isotope::Engine::Daemon;

use strict;
use warnings;
use bytes;
use base 'Isotope::Engine::Synchronous';

use Errno               qw[];
use HTTP::MessageParser qw[];
use IO::Handle          qw[SEEK_SET];
use IO::Socket::INET    qw[AF_INET INADDR_ANY SOCK_STREAM SOMAXCONN];
use IO::String          qw[];
use POSIX               qw[WNOHANG];
use Time::HiRes         qw[sleep];
use URI                 qw[];
use Isotope::Exceptions qw[throw_engine];
use Moose               qw[has];

BEGIN {

    if ( $^O eq 'MSWin32' && $^V lt v5.8.0 ) {
        *reap_children = \&reap_children_win32;
    }
    else {
        *reap_children = \&reap_children_posix;
    }
}

has 'bufsize'     => ( isa       => 'Int',
                       is        => 'rw',
                       required  => 1,
                       default   => 0 );

has 'max_clients' => ( isa       => 'Int',
                       is        => 'rw',
                       required  => 1,
                       default   => 12 );

has 'host'        => ( isa       => 'Value',
                       is        => 'rw',
                       required  => 1,
                       default   => '0.0.0.0' );

has 'port'        => ( isa       => 'Int',
                       is        => 'rw',
                       required  => 1,
                       default   => 3000 );

has 'base'        => ( isa       => 'Uri',
                       is        => 'rw',
                       coerce    => 1 );

has 'children'    => ( isa       => 'HashRef',
                       is        => 'rw',
                       default   => sub { {} } );

has 'continue'    => ( isa       => 'Bool',
                       is        => 'rw',
                       default   => 1 );

sub run {
    my $self   = shift;
    my $socket = $self->create_socket;
    my $base   = $self->create_base($socket);

    $self->base($base);

    $SIG{INT} = $SIG{TERM} = sub {
        $self->continue(0);
        $self->log->debug("Server caught signal: '$_[0]'.");
    };

    $self->log->info("Server is listening at $base.");

    while ( $self->continue ) {

        $self->reap_children;

        if ( $self->children_count >= $self->max_clients ) {
            $self->log->warn("Server has reached max clients.");
            sleep(0.100) && next;
        }

        my $connection = $socket->accept('Isotope::Engine::Daemon::Connection');

        unless ( defined $connection ) {

            if ( $self->continue ) {
                $self->log->error("Could not accept a new connection. Reason: '$!'.");
            }

            next;
        }

        my $peer = sprintf( "%s:%s", $connection->peerhost, $connection->peerport );
        my $pid  = fork();

        unless ( defined $pid ) {
            $connection->close;
            $self->log->error("Could not fork a new child process. Reason: '$!'.");
            sleep(0.100) && next;
        }

        unless ( $pid ) {

            $SIG{TERM} = 'DEFAULT';
            $SIG{INT}  =  sub {
                $self->continue(0);
                $self->log->debug("Child caught signal: '$_[0]'.");
                $SIG{INT} = 'DEFAULT';
            };

            if ( $self->bufsize == 0 ) {

                my $bufsize = ( $connection->stat )[11] || 8192;

                $self->bufsize($bufsize);
                $self->log->debug("Client bufsize $bufsize.");
            }

            $self->handle_connection($connection);

            exit(0);
        }

        $self->log->debug("Forked a new child process $pid.");
        $self->log->debug("Accepted a new connection from $peer.");
        $self->children->{ $pid } = $peer;
    }

    $self->shutdown;
}

sub children_count {
    my $self = shift;
    return scalar keys %{ $self->children };
}

sub create_socket {
    my $self = shift;

    my $socket = IO::Socket::INET->new(
        Proto     => 'tcp',
        LocalAddr => $self->host,
        LocalPort => $self->port,
        ReuseAddr => 1,
        Type      => SOCK_STREAM,
        Listen    => SOMAXCONN
    );

    unless ( defined $socket ) {

        my $port = $self->port;

        throw_engine message => qq/Could not create listener socket on port '$port'./,
                     payload => $@;
    }

    return $socket;
}

sub create_base {
    my ( $self, $socket ) = @_;

    my $addr = $socket->sockaddr;
    my $host = undef;

    if ( $addr eq INADDR_ANY ) {
        require Sys::Hostname;
        $host = Sys::Hostname::hostname();
    }
    else {
        $host = gethostbyaddr( $addr, AF_INET ) || Socket::inet_ntoa($addr);
    }

    my $base = URI->new;
    $base->scheme('http');
    $base->host($host);
    $base->port( $self->port );
    $base->path('/');

    return $base->canonical;
}

sub shutdown {
    my $self = shift;

    $self->log->debug("Server is shutting down.");

    $SIG{CHLD} = 'DEFAULT';

    kill 'INT' => keys %{ $self->children };

    while ( $self->children_count ) {
        $self->reap_children;
    }
}

sub handle_connection {
    my ( $self, $connection ) = @_;

    my $c = $self->construct_connection;

  TRANSACTION:

    my $t = $self->construct_transaction( connection => $c );

    $self->handle( $t, $connection );

    if ( $self->continue && !$t->connection->aborted && $t->connection->keepalive ) {

        $t->connection->transactions( $t->connection->transactions + 1 );

        goto TRANSACTION;
    }

    $connection->close;
}

sub handle_exception {
    my ( $self, $t, $e, $c ) = @_;

    local $@ = $e;

    if ( Isotope::Exception::Engine->caught && $e->has_payload ) {

        no warnings 'numeric';

        if ( $e->payload == 0 ) {
            $t->connection->aborted(1);
        }
        elsif ( $e->payload == Errno::ECONNRESET ) {
            $t->connection->aborted(1);
        }
        elsif ( $e->payload == Errno::EPIPE ) {
            $t->connection->aborted(1);
        }

        if ( $t->connection->aborted ) {

            my $remote  = sprintf "%s:%s", $t->connection->remote_ip, $t->connection->remote_port;
            my $message = $e->payload == 0 ? $e->message : $e->payload;

            $self->log->debug("Client $remote has aborted connection. Reason: $message.");

            return 0;
        }
    }
    
    # Close connection on all exceptions caused by engine
    $t->response->header( 'Connection' => 'close' );

    return $self->SUPER::handle_exception( $t, $e, $c );
}

sub read_connection {
    my ( $self, $t, $c ) = @_;

    $t->connection->local_host( $self->base->host );
    $t->connection->local_ip( $c->sockhost );
    $t->connection->local_port( $c->sockport );
    $t->connection->remote_ip( $c->peerhost );
    $t->connection->remote_port( $c->peerport );
}

sub read_request_headers {
    my ( $self, $t, $c ) = @_;

    my ( $buffer, $r, $offset, $bufsize ) = ( undef, 0, 0, $self->bufsize );

    while () {

         $r = $c->sysread( $buffer, $bufsize, $offset );

         unless ( defined $r ) {

             if ( $! == Errno::EINTR ) {

                 next if $offset || $self->continue;

                 throw_engine message => qq/Server is shutting down/,
                              payload => 0;
             }

             throw_engine message => qq/Could not read request headers from client./,
                          payload => $!;
         }

         if ( $r == 0 ) {

             throw_engine message => qq/End of file found/,
                          payload => 0;
         }

         if ( index( $buffer, "\x0d\x0a\x0d\x0a" ) >= 0 ) {
             last;
         }

         if ( $offset >= 16 * 1024 ) {

             throw_engine message => qq/Request Entity Too Large/,
                          status  => 413;
         }

         $offset += $r;
     }

     my ( $method, $uri, $protocol, $headers, $unread ) = eval {
         HTTP::MessageParser->parse_request(\$buffer);
     };

     if ( $@ ) {

         throw_engine message => qq/Bad Request./,
                      status  => 400;
     }

     $c->unread($unread);

     $t->request->method($method);
     $t->request->protocol($protocol);
     $t->request->headers($headers);

     my $base = $self->base->clone;

     if ( $t->request->has_header('Host') ) {
         $base->host_port( $t->request->header('Host') );
         $base = $base->canonical;
     }

     $t->request->uri( URI->new_abs( $uri, $base ) );
     $t->request->base($base);

     if ( $t->request->has_header('Transfer-Encoding') ) {

         if ( lc $t->request->header('Transfer-Encoding') ne 'identity' ) {

             throw_engine message => 'Length Required',
                          status  => 411;
         }
     }

     if ( $t->request->has_header('Expect') ) {

         my $expect = lc $t->request->header('Expect');

         unless ( $expect eq '100-continue' ) {

             throw_engine message => qq/Server could not meet expectation '$expect'./,
                          status  => 417;
         }

         my $response = "HTTP/1.1 100 Continue\x0d\x0a\x0d\x0a";

         my ( $r, $w, $s ) = ( length $response, 0, 0 );

         for ( $w = 0; $w < $r; $w += $s || 0 ) {

             $s = $c->syswrite( $response, $r - $w, $w );

             unless ( defined $s ) {

                 next if $! == Errno::EINTR;

                 throw_engine message => qq/Could not send a 100 Continue response./,
                              payload => $!;
             }
         }
    }
}

sub read_request_content_handle {
    my ( $self, $t, $c ) = @_;

    my $length  = $t->request->content_length;
    my $bufsize = $self->bufsize;

    my ( $handle, $buffer, $r, $w, $s, $offset ) = ( undef, undef, 0, 0, 0, 0 );

    while ( $length ) {

        $r = $c->sysread( $buffer, $length < $bufsize ? $length : $bufsize );

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

        $length -= $r;
        $offset += $r;
    }

    if ( defined $handle ) {

        $handle->sysseek( 0, SEEK_SET )
          or throw_engine message => qq/Could not seek content handle./,
                          payload => $!;
    }

    return ( $offset, $handle );
}

sub read_request_content_string {
    my ( $self, $t, $c ) = @_;

    my $length  = $t->request->content_length;
    my $bufsize = $self->bufsize;

    my ( $string, $buffer, $offset, $r ) = ( undef, undef, 0, 0 );

    while ( $length ) {

        $r = $c->sysread( $buffer, $length < $bufsize ? $length : $bufsize, $offset );

        unless ( defined $r ) {

            next if $! == Errno::EINTR;

            throw_engine message => qq/Could not read request content from client./,
                         payload => $!;
        }

        last unless $r;

        unless ( defined $string ) {
            $string = \$buffer;
        }

        $length -= $r;
        $offset += $r;
    }

    return ( $offset, $string );
}

sub send_response_headers {
    my ( $self, $t, $c ) = @_;

    if ( !$t->response->is_header_only && $t->response->has_content && !$t->response->content_length ) {

        if ( $t->response->protocol_version >= 1001 ) {
            $t->response->header( 'Transfer-Encoding' => 'chunked' );
        }
        else {
            $t->response->header( 'Connection' => 'close' );
        }
    }
    
    if ( !$self->continue ) {
        $t->response->header( 'Connection' => 'close' );
    }

    if ( $t->connection->keepalive ) {
        $t->response->header( 'Connection' => 'Keep-Alive' );
        $t->response->header( 'Keep-Alive' => 'timeout=60, max=100' );
    }

    my $response  = sprintf "%s %s\x0d\x0a", $t->response->protocol, $t->response->status_line;
       $response .= $t->response->headers->as_string . "\x0d\x0a";

    my ( $r, $w, $s ) = ( length $response, 0, 0 );

    for ( $w = 0; $w < $r; $w += $s || 0 ) {

        $s = $c->syswrite( $response, $r - $w, $w );

        unless ( defined $s ) {

            next if $! == Errno::EINTR;

            throw_engine message => qq/Could not send response headers to client./,
                         payload => $!;
        }
    }

    return $r;
}

sub send_response_content_handle {
    my ( $self, $t, $handle, $c ) = @_;

    my $chunked = $t->response->has_header('Transfer-Encoding') ? 1 : 0;
    my $bufsize = $self->bufsize;

=begin XXX

    if ( HAS_SENDFILE && !$chunked && defined $handle->fileno && $handle->fileno > 0 ) {

    }

=cut

    my ( $buffer, $r, $w, $n, $s, $l ) = ( undef, 0, 0, 0, 0, 0 );

    while () {

        $r = $handle->sysread( $buffer, $bufsize );

        unless ( defined $r ) {

            next if $! == Errno::EINTR;

            throw_engine message => qq/Could not read from response content handle./,
                         payload => $!;
        }

        $n = $r;

        if ( $chunked ) {

            if ( $r == 0 ) {
                $buffer = "0\x0d\x0a\x0d\x0a";
            }
            else {
                $buffer = sprintf "%x\x0d\x0a%s\x0d\x0a", $r, $buffer;
            }

            $n = length $buffer;
        }

        for ( $w = 0; $w < $n; $w += $s || 0 ) {

            $s = $c->syswrite( $buffer, $n - $w, $w );

            unless ( defined $s ) {

                next if $! == Errno::EINTR;

                throw_engine message => qq/Could not send response content handle to client./,
                             payload => $!;
            }
        }

        last unless $r;

        $l += $r;
    }

    return $l;
}

sub send_response_content_string {
    my ( $self, $t, $string, $c ) = @_;

    if ( $t->response->has_header('Transfer-Encoding') ) {
        return $self->send_response_content_handle( $t, IO::String->new($string), $c );
    }

    my ( $r, $w, $s ) = ( length $$string, 0, 0 );

    for ( $w = 0; $w < $r; $w += $s || 0 ) {

        $s = $c->syswrite( $$string, $r - $w, $w );

        unless ( defined $s ) {

            next if $! == Errno::EINTR;

            throw_engine message => qq/Could not send response content string to client./,
                         payload => $!;
        }
    }

    return $r;
}

sub reap_children_posix {
    my $self = shift;

    while () {

        my $pid = waitpid( -1, WNOHANG );

        last if $pid == 0 || $pid == -1;

        delete $self->children->{ $pid };

        $self->log->debug("Reaped child process $pid.");
    }
}

# Win32 Perl 5.6.1
sub reap_children_win32 {
    my $self = shift;

    foreach my $pid ( keys %{ $self->children } ) {

        next if waitpid( $pid, WNOHANG ) != -1;

        delete $self->children->{ $pid };

        $self->log->debug("Reaped child process $pid.");
    }
}

1;

package Isotope::Engine::Daemon::Connection;

use strict;
use warnings;
use bytes;
use base 'IO::Socket::INET';

sub buffer : lvalue {
    my $self = shift;
    ${*$self}{'buffer'} ||= '';
}

sub unread {
    my $self   = shift;
    my $buffer = \$self->buffer;

    if ( @_ ) {

        my $prepend = ref $_[0] ? shift : \shift;

        if ( length $$buffer ) {
            $$buffer = $$prepend . $$buffer;
        }
        else {
            $$buffer = $$prepend;
        }
    }

    return 1;
}


sub sysread {
    my $self   = shift;
    my $length = $_[1];
    my $buffer = \$self->buffer;
    my $buflen = length $$buffer;

    if ( $buflen == 0 ) {
        return $self->SUPER::sysread(@_);
    }

    if ( $buflen >= $length ) {

        if ( $_[2] ) {
            substr( $_[0], $_[2] ) = substr( $$buffer, 0, $length, '' );
        }
        else {
            $_[0] = substr( $$buffer, 0, $length, '' );
        }

        return $length;
    }

    my ( $result, $r ) = ( 0, 0 );

    $length -= $buflen;
    $result += $buflen;

    $r = $self->SUPER::sysread( $$buffer, $length, $buflen );

    unless ( defined $r ) {
        return undef;
    }

    $result += $r;

    if ( $_[2] ) {
        substr( $_[0], $_[2] ) = $$buffer;
    }
    else {
        $_[0] = $$buffer;
    }

    $$buffer = '';

    return $result;
}

1;
