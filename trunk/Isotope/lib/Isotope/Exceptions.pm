package Isotope::Exceptions;

use strict;
use warnings;

BEGIN {

    my %classes = (
        'Isotope::Exception' => {
            description => 'Generic Isotope exception',
            fields      => [ qw(headers payload status status_message) ],
            alias       => 'throw'
        },
        'Isotope::Exception::Dispatcher' => {
            isa         => 'Isotope::Exception',
            description => 'Dispatcher exception',
            fields      => 'path',
            alias       => 'throw_dispatcher'
        },
        'Isotope::Exception::Engine' => {
            isa         => 'Isotope::Exception',
            description => 'Engine exception',
            alias       => 'throw_engine'
        },
        'Isotope::Exception::IO' => {
            isa         => 'Isotope::Exception',
            description => 'IO exception',
            alias       => 'throw_io'
        },
        'Isotope::Exception::Parameter' => {
            isa         => 'Isotope::Exception',
            description => 'Invalid parameters was given to method/function',
            alias       => 'throw_param'
        },
        'Isotope::Exception::Plugin' => {
            isa         => 'Isotope::Exception',
            fields      => 'plugin',
            description => 'Plugin exception',
            alias       => 'throw_plugin'
        }
    );
    
    my @exports = map { $classes{ $_ }->{ alias } } keys %classes;
    
    require Exception::Class;
    require Sub::Exporter;
    
    Exception::Class->import(%classes);
    Sub::Exporter->import( -setup => { exports => \@exports  } );
}

package Isotope::Exception;

use strict;
no  warnings 'redefine';

use HTTP::Headers qw[];
use HTTP::Status  qw[];
use Scalar::Util  qw[blessed];

sub headers {
    my $self    = shift;
    my $headers = $self->{headers};

    unless ( defined $headers ) {
        return undef;
    }

    if ( blessed $headers && $headers->isa('HTTP::Headers') ) {
        return $headers;
    }

    if ( ref $headers eq 'ARRAY' ) {
        return $self->{headers} = HTTP::Headers->new( @{ $headers } );
    }

    if ( ref $headers eq 'HASH' ) {
        return $self->{headers} = HTTP::Headers->new( %{ $headers } );
    }

    Exception::Class::Base->throw(
        message => qq/Can't coerce a '$headers' into a HTTP::Headers instance./
    );
}

sub status {
    return $_[0]->{status} ||= 500;
}

sub is_info {
    return HTTP::Status::is_info( $_[0]->status );
}

sub is_success {
    return HTTP::Status::is_success( $_[0]->status );
}

sub is_redirect {
    return HTTP::Status::is_redirect( $_[0]->status );
}

sub is_error {
    return HTTP::Status::is_error( $_[0]->status );
}

sub is_client_error {
    return HTTP::Status::is_client_error( $_[0]->status );
}

sub is_server_error {
    return HTTP::Status::is_server_error( $_[0]->status );
}

sub status_line {
    return sprintf "%s %s", $_[0]->status, $_[0]->status_message;
}

sub status_message {
    return $_[0]->{status_message} ||= HTTP::Status::status_message( $_[0]->status );
}

my %messages = (
    400 => 'Browser sent a request that this server could not understand.',
    401 => 'The requested resource requires user authentication.',
    403 => 'Insufficient permission to access the requested resource on this server.',
    404 => 'The requested resource was not found on this server.',
    405 => 'The requested method is not allowed.',
    500 => 'The server encountered an internal error or misconfiguration and was unable to complete the request.',
    501 => 'The server does not support the functionality required to fulfill the request.',
);

sub public_message {
    return $messages{ $_[0]->status } || '';
}

sub as_public_html {
    my $self    = shift;
    my $title   = shift || $self->status_line;
    my $header  = shift || $self->status_message;
    my $message = shift || $self->public_message;

return <<EOF;
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html>
  <head>
    <title>$title</title>
  </head>
  <body>
    <h1>$header</h1>
    <p>$message</p>
  </body>
</html>
EOF

}

sub has_headers {
    return defined $_[0]->{headers} ? 1 : 0;
}

sub has_payload {
    return defined $_[0]->{payload} && length $_[0]->{payload} ? 1 : 0;
}

sub has_status_message {
    return defined $_[0]->{status_message} ? 1 : 0;
}

sub full_message {
    my $self    = shift;
    my $message = $self->message;

    if ( $self->has_payload ) {
        $message .= sprintf " %s.", $self->payload;
    }

    return $message;
}

1;
