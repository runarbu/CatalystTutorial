package Isotope::Engine::Synchronous;

use strict;
use warnings;
use bytes;
use base 'Isotope::Engine';

use Errno               qw[];
use IO::Handle          qw[];
use Isotope::Exceptions qw[throw_engine];
use Scalar::Util        qw[];

sub handle {
    my ( $self, $t, @arguments ) = @_;
    $self->read_connection    ( $t, @arguments ) unless $t->connection->transactions;
    $self->read_request       ( $t, @arguments ) unless $t->connection->aborted;
    $self->handle_transaction ( $t )             unless $t->connection->aborted || $t->response->is_error;
    $self->send_response      ( $t, @arguments ) unless $t->connection->aborted;
}

sub read_request {
    my ( $self, $t, @arguments ) = @_;

    eval {
        $self->read_request_headers( $t, @arguments );
        $self->read_request_content( $t, @arguments );
    };

    if ( my $e = $@ ) {
        $self->handle_exception( $t, $e, @arguments );
    }
}

sub read_request_content {
    my ( $self, $t, @arguments ) = @_;

    # RFC 1945 - 7.2 Entity Body
    # An entity body is included with a request message only when the
    # request method calls for one. The presence of an entity body in a
    # request is signaled by the inclusion of a Content-Length header field
    # in the request message headers. HTTP/1.0 requests containing an
    # entity body must include a valid Content-Length header field.

    # RFC 2616 - 4.3 Message Body
    # The presence of a message-body in a request is signaled by the
    # inclusion of a Content-Length or Transfer-Encoding header field in
    # the request's message-headers.

    return 0 unless $t->request->has_header('Content-Length')
                 || $t->request->has_header('Transfer-Encoding');

    if ( $t->request->has_header('Transfer-Encoding') ) {

        if ( lc $t->request->header('Transfer-Encoding') eq 'identity' ) {

            # HTTP/1.1 Specification Errata
            # http://skrb.org/ietf/http_errata.html#identity
            $t->request->headers->remove('Transfer-Encoding');

            return 0 unless $t->request->content_length;
        }
    }

    if ( $t->request->has_header('Content-Length') ) {
        return 0 unless $t->request->content_length > 0;
    }

    my ( $bytes_read, $content );

    if ( $self->content_as eq 'handle' ) {
        ( $bytes_read, $content ) = $self->read_request_content_handle( $t, @arguments );
    }
    else {
        ( $bytes_read, $content ) = $self->read_request_content_string( $t, @arguments );
    }
    
    if ( $bytes_read > 0 ) {
        $t->request->content($content);
    }

    unless ( $t->request->has_header('Content-Length') ) {
        return $bytes_read;
    }

    my $content_length = $t->request->content_length;

    if ( $bytes_read > $content_length ) {
        throw_engine message => "Request content length ($bytes_read) was greater than the "
                              . "length specified in Content-Length ($content_length).",
                     status  => 400;
    }

    if ( $bytes_read < $content_length ) {
        throw_engine message => "Request content length ($bytes_read) was less than the "
                              . "length specified in Content-Length ($content_length).",
                     status  => 400;
    }

    return $bytes_read;
}

sub send_response {
    my ( $self, $t, @arguments ) = @_;

    unless ( $t->response->has_protocol ) {
        $t->response->protocol( $t->request->protocol );
    }

    unless ( $t->response->is_header_only || $t->response->has_content ) {

        if ( $t->response->content_length ) {

            my $length = $t->response->content_length;
            my $status = $t->response->status_line;

            $self->log->warn("Response with status $status and Content-Length of $length without content.");
        }
        elsif ( $t->response->status == 200 ) {

            my $status = $t->response->status_line;

            $self->log->warn("Response with status $status without content.");
        }

        $t->response->headers->remove('Content-Length');
        $t->response->headers->remove('Transfer-Encoding');
    }

    eval {
        $self->send_response_headers( $t, @arguments );
        $self->send_response_content( $t, @arguments );
    };

    if ( my $e = $@ ) {
        $self->handle_exception( $t, $e, @arguments );
    }
}

sub send_response_content {
    my ( $self, $t, @arguments ) = @_;

    # RFC 2616 - 4.3 Message Body
    # For response messages, whether or not a message-body is included with
    # a message is dependent on both the request method and the response
    # status code (section 6.1.1). All responses to the HEAD request method
    # MUST NOT include a message-body, even though the presence of entity-
    # header fields might lead one to believe they do. All 1xx
    # (informational), 204 (no content), and 304 (not modified) responses
    # MUST NOT include a message-body. All other responses do include a
    # message-body, although it MAY be of zero length.

    return 0 if $t->response->is_header_only;

    if ( $t->response->has_header('Content-Length') ) {
        return 0 unless $t->response->content_length > 0;
    }
    
    return 0 unless $t->response->has_content;

    my ( $bytes_sent, $content ) = ( 0, $t->response->content_ref );

    if ( ref $content eq 'SCALAR' ) {
        $bytes_sent = $self->send_response_content_string( $t, $content, @arguments );
    }
    elsif ( my $handle = Scalar::Util::openhandle($content) ) {
        $bytes_sent = $self->send_response_content_handle( $t, $handle, @arguments );
    }
    else {
        throw_engine qq/Can't handle response content '$content'./;
    }
    
    unless ( $t->response->has_header('Content-Length') ) {
        return $bytes_sent;
    }

    my $content_length = $t->response->content_length;

    if ( $bytes_sent > $content_length ) {
        $self->log->warn( "Response content length ($bytes_sent) was greater than ",
                          "the length specified in Content-Length ($content_length)." );
    }

    if ( $bytes_sent < $content_length ) {
        $self->log->warn( "Response content length ($bytes_sent) was less than ",
                          "the length specified in Content-Length ($content_length)." );
    }

    return $bytes_sent;
}

sub run                          { }
sub read_connection              { }
sub read_request_headers         { }
sub read_request_content_handle  { }
sub read_request_content_string  { }
sub send_response_headers        { }
sub send_response_content_string { }
sub send_response_content_handle { }

1;
