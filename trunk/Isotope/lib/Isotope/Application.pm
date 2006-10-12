package Isotope::Application;

use strict;
use warnings;
use bytes;
use base 'Isotope::Object';

use Isotope::Connection  qw[];
use Isotope::Exceptions  qw[];
use Isotope::Log         qw[];
use Isotope::Request     qw[];
use Isotope::Response    qw[];
use Isotope::Transaction qw[];
use Moose                qw[has];

has 'dispatcher' => ( isa       => 'Isotope::Dispatcher',
                      is        => 'rw',
                      required  => 1,
                      trigger   => sub {
                          my ( $self, $dispatcher ) = @_;
                          $dispatcher->application($self);
                      });

has 'engine'     => ( isa       => 'Isotope::Engine',
                      is        => 'rw',
                      required  => 1,
                      trigger   => sub {
                          my ( $self, $engine ) = @_;
                          $engine->application($self);
                      });

has 'log'        => ( isa       => 'Object',
                      is        => 'rw',
                      predicate => 'has_log' );

has 'plugins'    => ( isa       => 'ArrayRef',
                      is        => 'ro',
                      predicate => 'has_plugins' );

sub BUILD {
    my ( $self, $params ) = @_;

    unless ( $self->has_log ) {
        $self->log( $self->construct_log($self) );
    }
}

sub construct_connection {
    my $self = shift;
    return Isotope::Connection->new(@_);
}

sub construct_log {
    my ( $self, $object ) = @_;
    return Isotope::Log->new( category => ref $object );
}

sub construct_request {
    my $self = shift;
    return Isotope::Request->new(@_);
}

sub construct_response {
    my $self = shift;
    return Isotope::Response->new(@_);
}

sub construct_transaction {
    my ( $self, %params ) = @_;

    $params{connection} ||= $self->construct_connection;
    $params{request}    ||= $self->construct_request;
    $params{response}   ||= $self->construct_response;

    return Isotope::Transaction->new(%params);
}

# this called by handle_transaction and eventually subrequests
# XXX hooks/plugins
sub dispatch {
    my ( $self, $transaction, $path, @arguments ) = @_;
    $self->dispatcher->dispatch( $transaction, $path, @arguments );
}

# this might get moved to engine. If application cares it can catch exceptions
# before it reaches engine.
sub handle_exception {
    my ( $self, $t, $e ) = @_;

    local $@ = $e;

    if ( Isotope::Exception->caught ) {

        if ( $e->is_error ) {
            $t->response->headers->remove_content_headers;
        }

        if ( $e->has_headers ) {
            $t->response->headers->merge( $e->headers );
        }

        $t->response->status( $e->status );
        $t->response->status_message( $e->status_message );

        if ( ! $e->is_success && $e->status !~ /^1\d\d|[23]04$/ ) {

            $t->response->content( $e->as_public_html );
            $t->response->content_type('text/html');
            $t->response->content_length( length $t->response->content );
        }

        if ( $e->is_server_error ) {
            
            if ( $self->log->is_debug ) {
                $e->show_trace(1);
            }

            $self->log->error( $e->as_string );
        }
        elsif ( $e->is_client_error ) {
            $self->log->warn( $e->as_string ) if $e->status =~ /^40[034]$/;
        }
        elsif ( $e->is_redirect ) {
            $self->log->info( $e->as_string );
        }
    }
    else {

        $t->response->headers->remove_content_headers;

        $t->response->status(500);
        $t->response->status_message('Internal Server Error');
        $t->response->content_type('text/html');
        $t->response->content( <<'EOF' );
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html>
  <head>
    <title>500 Internal Server Error</title>
  </head>
  <body>
    <h1>Internal Server Error</h1>
    <p>The server encountered an internal error or misconfiguration and was unable to complete the request.</p>
  </body>
</html>
EOF

        $t->response->content_length( length $t->response->content );

        $self->log->error("$e");
    }
}

# this is called by engine when a transaction is available, this is the place
# to do any transformations on transaction before/after it's dispatched to
# dispatcher.
# XXX plugins/hooks
sub handle_transaction {
    my ( $self, $transaction, @arguments ) = @_;
    $self->dispatch( $transaction, $transaction->request->path, @arguments );
}

sub run {
    my ( $self, @arguments ) = @_;
    return $self->engine->run(@arguments);
}

sub setup {
    my ( $self, @arguments ) = @_;

    $self->engine->setup;
    $self->dispatcher->setup;

    return $self;
}

1;
