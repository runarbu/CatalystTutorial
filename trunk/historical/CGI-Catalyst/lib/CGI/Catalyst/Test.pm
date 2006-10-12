package CGI::Catalyst::Test;

use strict;

use CGI::Catalyst;

use Carp ();
use IO::File;
use HTTP::Request;
use HTTP::Response;
use HTTP::Status;
use URI;

sub import {
    my $self  = shift;
    my $class = shift;

    my ( $get, $request );
    
    eval "require $class";

    if ( my $error = $@ ) {
        Carp::croak( qq/Couldn't load "$class", "$error"/ );
    }

    $class->import;

    $request = sub { $self->request( @_, $class )          };
    $get     = sub { $self->request( @_, $class )->content };

    {
        no strict 'refs';
        my $caller = caller(0);
        *{"$caller\::request"} = $request;
        *{"$caller\::get"}     = $get;
    }
}

sub request {
    my ( $class, $request, $application ) = @_;

    unless ( ref $request ) {
        $request = URI->new( $request, 'http' );
    }
    
    unless ( ref $request eq 'HTTP::Request' ) {
        $request = HTTP::Request->new( 'GET', $request );
    }
    
    unless ( ref $application ) {
        $application = $application->new;
    }

    local ( *STDIN, *STDOUT );
    local ( %ENV );
    
    no warnings 'uninitialized';

    $ENV{CONTENT_TYPE}      = $request->header('Content-Type');
    $ENV{CONTENT_LENGTH}    = $request->header('Content-Length');
    $ENV{GATEWAY_INTERFACE} = 'CGI/1.1';
    $ENV{HTTP_HOST}         = sprintf( "%s:%d", $request->uri->host, $request->uri->port );
    $ENV{QUERY_STRING}      = $request->uri->query || '';
    $ENV{REQUEST_METHOD}    = $request->method;
    $ENV{PATH_INFO}         = $request->uri->path  || '/';
    $ENV{REMOTE_ADDR}       = '127.0.0.1';
    $ENV{SCRIPT_NAME}       = '/';
    $ENV{SERVER_NAME}       = $request->uri->host;
    $ENV{SERVER_PORT}       = $request->uri->port;
    $ENV{SERVER_PROTOCOL}   = 'HTTP/1.1';
    $ENV{SERVER_SOFTWARE}   = "CGI::Catalyst/$CGI::Catalyst::VERSION";

    for my $field ( $request->header_field_names ) {

        next if $field =~ /^Content-(Length|Type)$/;

        $field =~ s/-/_/g;
        $ENV{ 'HTTP_' . uc($field) } = $request->header($field);
    }

    if ( $request->content_length ) {
        my $body = IO::File->new_tmpfile;
        $body->print( $request->content ) or die $!;
        $body->seek( 0, SEEK_SET ) or die $!;
        open( STDIN, "<&=", $body->fileno )
          or die("Failed to dup \$body: $!");
    }

    my $output = '';
    
    # XXX requires perl5.8.0
    open( STDOUT, '>', \$output );

    require CGI;
    CGI::initialize_globals();
    $application->run;

    my $status   = $application->response->status;
    my $message  =  HTTP::Status::status_message($status);

    $output = sprintf( "HTTP/1.1 %d %s\015\012", $status, $message ) . $output;

    return HTTP::Response->parse($output);
}

1;
