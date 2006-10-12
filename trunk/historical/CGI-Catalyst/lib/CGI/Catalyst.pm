package CGI::Catalyst;

use strict;
use base qw[ Class::Accessor::Fast Class::Data::Inheritable ];
use vars qw[ $ACTIONS @PACKAGES %SEEN ];

use Carp;
use CGI::Catalyst::Request;
use CGI::Catalyst::Response;

our $VERSION = '0.01';

BEGIN {
    __PACKAGE__->mk_accessors( qw[ cgi debug request response state ] );
    __PACKAGE__->mk_classdata( 'actions' => {} );
}

sub FETCH_CODE_ATTRIBUTES {
    my ( $package, $code ) = @_;

    if ( my $action = $ACTIONS->{"$code"} ) {
        return @{ $ACTIONS->{"$code"}->[2] };
    }

    return ();
}

sub MODIFY_CODE_ATTRIBUTES {
    my ( $package, $code, @attributes ) = @_;

    my ( @action, @return );

    while ( my $attribute = shift(@attributes) ) {

        if ( $attribute =~ /^(Private|Path\(.*\))$/ ) {
            push @action, $attribute;
        }

        else {
            push @return, $attribute;
        }
    }

    if ( scalar(@action) ) {

        unless ( $SEEN{$package} ) {
            push @PACKAGES, $package;
            $SEEN{$package}++;
        }

        $ACTIONS->{"$code"} = [ $package, $code, \@action ];
    }

    return @return;
}

sub CHECK {

    my $findname = sub {
        my ( $package, $code ) = @_;

        no strict 'refs';
        for my $symbol ( values %{ $package . '::' } ) {
            if ( *{$symbol}{CODE} && *{$symbol}{CODE} == $code ) {
                return *{$symbol}{NAME};
            }
        }
    };

    # trap some common mistakes
    my %bad = map { $_ => 1 } qw[
      actions
      can
      cgi
      config
      dispatch
      execute
      error
      finalize
      forward
      handler
      isa
      new
      prepare
      request
      response
      stash
    ];

    for my $package ( @PACKAGES ) {

        # take a copy here to get inherited actions
        my $actions = { %{ $package->actions } };

        {
            no strict 'refs';

            for my $isa ( @{"$package\::ISA"} ) {

                # we only care about packages that inherits from CGI::Catalyst
                next unless $SEEN{$isa};

                # a inherited package may not override any previous declared actions
                $actions = { %{ $isa->actions }, %{ $actions } };
            }
        }

        # set our own copy to break the reference/inheritance
        $package->actions($actions);

        for my $action ( grep { $_->[0] eq $package } values %{ $ACTIONS } ) {

            my $package    = $action->[0];
            my $code       = $action->[1];
            my $attribute  = $action->[2]->[0];
            my $method     = &$findname( $package, $code );

            # assign method name to action, for future use
            $action->[3] = $method;

            if ( exists $bad{$method} ) {
                Carp::croak(qq/Invalid method name '$package->$method' for action./);
            }

            if ( scalar( @{ $action->[2] } ) > 1 ) {
                Carp::croak(qq/Invalid combination of attributes in '$package->$method' for action./);
            }

            if ( $attribute =~ m/^Private$/ ) {

                unless ( $method =~ /^(begin|default|end)$/ ) {
                    Carp::croak(qq/Invalid method name '$package->$method' for Private action./);
                }

                $package->actions->{$method} = $code;
            }

            elsif ( $attribute =~ m/^Path\(\s*["']?(.+?)["']?\s*\)$/ ) {

                my $path = lc($1);

                # Make sure we have a absolute path
                unless ( $path =~ /^\/\S+$/ ) {
                    Carp::croak(qq/Invalid path '$1' in '$package->$method' for Path action./);
                }

                # No trailing slashes
                $path =~ s/\/$//;

                $package->actions->{$path} = $code;
            }

            else {
                Carp::croak(qq/Invalid action declaration in '$package->$method'./);
            }
        }
    }
}

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(
        {
            debug    => 0,
            error    => [],
            request  => CGI::Catalyst::Request->new,
            response => CGI::Catalyst::Response->new,
            state    => 0
        }
    );

    $self->initialize;
    return $self;
}

sub config {
    my $self = shift;

    if ( @_ ) {
        my $config = @_ > 1 ? {@_} : $_[0];
        while ( my ( $key, $val ) = each %$config ) {
            $self->{config}->{$key} = $val;
        }
    }

    return $self->{config};
}

sub dispatch {
    my $self = shift;

    if ( $self->actions->{ $self->request->action } ) {

        # Execute begin
        if ( my $begin = $self->actions->{begin} ) {
            $self->execute($begin);
            return if scalar @{ $self->error };
        }

        # Execute the action or default
        if ( my $action = $self->actions->{ $self->request->action } ) {
            $self->execute($action);
        }

        # Execute end
        if ( my $end = $self->actions->{end} ) {
            $self->execute($end);
        }
    }

    else {
        my $path  = $self->request->path;
        my $error = $path
          ? qq/Unknown resource "$path"/
          : "No default action defined";
        $self->error($error);
    }
}

sub error {
    my ( $self, $error ) = @_;

    if ( $error ) {

        if ( ref($error) eq 'ARRAY' ) {
            $self->{error} = [ @{ $error } ];
        }

        else {
            push @{ $self->{error} }, $error;
        }
    }

    return $self->{error};
}

sub execute {
    my ( $self, $code, $arguments ) = @_;

    unless ( ref($arguments) eq 'ARRAY' && scalar( @{ $arguments } ) ) {
        $arguments = $self->request->arguments;
    }

    eval {
        $self->state( &$code( $self, @{ $arguments } ) || 0 );
    };

    if ( my $error = $@ ) {

        unless ( ref $error ) {
            chomp $error;
            $error = qq/Caught exception "$error"/;
        }

        $self->error($error);
        $self->state(0);
    }

    return $self->state;
}

sub finalize {
    my $self = shift;

    $self->finalize_cookies;

    if ( my $location = $self->response->redirect ) {
        $self->response->header( Location => $location );
        $self->response->status(302) if $self->response->status !~ /^3\d\d$/;
    }

    if ( $#{ $self->error } >= 0 ) {
        $self->finalize_error;
    }

    if ( !$self->response->body && $self->response->status == 200 ) {
        $self->finalize_error;
    }

    if ( $self->response->body && !$self->response->content_length ) {
        require bytes;
        $self->response->content_length( bytes::length( $self->response->body ) );
    }

    if ( $self->response->status =~ /^(1\d\d|[23]04)$/ ) {
        $self->response->headers->remove_header("Content-Length");
        $self->response->body('');
    }

    if ( $self->request->method eq 'HEAD' ) {
        $self->response->body('');
    }

    $self->finalize_headers;
    $self->finalize_body;
}

sub finalize_body {
    my $self = shift;
    print $self->response->body;
}

sub finalize_cookies {
    my $self = shift;

    while ( my ( $name, $cookie ) = each %{ $self->response->cookies } ) {

        require CGI::Cookie;

        my $cookie = CGI::Cookie->new(
            -name    => $name,
            -value   => $cookie->{value},
            -expires => $cookie->{expires},
            -domain  => $cookie->{domain},
            -path    => $cookie->{path},
            -secure  => $cookie->{secure} || 0
        );

        $self->response->headers->push_header( 'Set-Cookie' => $cookie->as_string );
    }
}

sub finalize_error {
    my $self = shift;
    $self->response->content_type('text/plain');
    $self->response->body("oups\n");
}

sub finalize_headers {
    my $self = shift;

    $self->response->header( Status => $self->response->status );

    print $self->response->headers->as_string("\015\012");
    print "\015\012";
}

sub forward {
    my ( $self, $command, @arguments ) = @_;

    my $action;

    if ( $command =~ /^\// ) {

        $action = $self->actions->{ lc($command) };

        unless ( $action ) {
            $self->error( qq/Couldn't forward to path "$command"./ );
            return 0;
        }
    }

    else {

        $action = $self->can($command);

        unless ( $action ) {
            $self->error( qq/Couldn't forward to action "$command"./ );
            return 0;
        }
    }

    return $self->execute( $action, \@arguments );
}

sub handler : method {
    my ( $self, @arguments ) = @_;

    unless ( ref $self ) {
        $self = $self->new;
    }

    eval {
        $self->prepare(@arguments);
        $self->dispatch;
        $self->finalize;
    };

    if ( my $error = $@ ) {
        chomp $error;
        warn qq/Caught exception in engine "$error"/;
    }

    return $self->response->status;
}

sub initialize { }

sub prepare {
    my ( $self, @arguments ) = @_;

    $self->prepare_request(@arguments);
    $self->prepare_connection;
    $self->prepare_headers;
    $self->prepare_cookies;
    $self->prepare_path;
    $self->prepare_action;

    if ( $self->request->method eq 'POST' and $self->request->content_length ) {

        if ( $self->request->content_type eq 'application/x-www-form-urlencoded' ) {
            $self->prepare_parameters;
        }
        elsif ( $self->request->content_type eq 'multipart/form-data' ) {
            $self->prepare_parameters;
            $self->prepare_uploads;
        }
        else {
            $self->prepare_body;
        }
    }

    if ( $self->request->method eq 'GET' ) {
        $self->prepare_parameters;
    }
}

sub prepare_action {
    my $self = shift;

    my @arguments = ();
    my @fragments = split '/', $self->request->path;

    while ( @fragments ) {

        my $path = '/' . join '/', @fragments;

        if ( my $action = $self->actions->{$path} ) {
            $self->request->action($path);
            last;
        }

        else {
            unshift @arguments, pop @fragments;
        }
    }

    $self->request->arguments( \@arguments );

    unless ( $self->request->action ) {
        $self->request->action('default');
    }
}

sub prepare_body {
    my $self = shift;

    # XXX this is undocumented in CGI.pm. If Content-Type is not
    # application/x-www-form-urlencoded or multipart/form-data
    # CGI.pm will read STDIN into a param, POSTDATA.

    $self->request->body( $self->cgi->param('POSTDATA') );
}

sub prepare_cookies {
    my $self = shift;

    if ( my $header = $self->request->header('Cookie') ) {

        require CGI::Cookie;

        $self->request->cookies( { CGI::Cookie->parse($header) } );
    }
}

sub prepare_connection {
    my $self = shift;

    $self->request->address( $ENV{REMOTE_ADDR} );
    $self->request->hostname( $ENV{REMOTE_HOST} );
    $self->request->protocol( $ENV{SERVER_PROTOCOL} );
    $self->request->user( $ENV{REMOTE_USER} );

    if ( $ENV{HTTPS} && uc( $ENV{HTTPS} ) eq 'ON' ) {
        $self->request->secure(1);
    }

    if ( $ENV{SERVER_PORT} == 443 ) {
        $self->request->secure(1);
    }
}

sub prepare_headers {
    my $self = shift;

    while ( my ( $header, $value ) = each %ENV ) {

        next unless $header =~ /^(HTTP|CONTENT)/i;

        ( my $field = $header ) =~ s/^HTTPS?_//;

        $self->request->header( $field => $value );
    }

    $self->request->method( $ENV{REQUEST_METHOD} || 'GET' );
}

sub prepare_parameters {
    my $self = shift;

    my ( @params );

    if ( $self->request->method eq 'POST' ) {
        for my $param ( $self->cgi->url_param ) {
            for my $value (  $self->cgi->url_param($param) ) {
                push ( @params, $param, $value );
            }
        }
    }

    for my $param ( $self->cgi->param ) {
        for my $value (  $self->cgi->param($param) ) {
            push ( @params, $param, $value );
        }
    }

    $self->request->param(@params);
}

sub prepare_path {
    my $self = shift;

    my $base;
    {
        my $scheme = $self->request->secure ? 'https' : 'http';
        my $host   = $ENV{HTTP_HOST}   || $ENV{SERVER_NAME};
        my $port   = $ENV{SERVER_PORT} || 80;
        my $path   = $ENV{SCRIPT_NAME} || '/';

        if ( $host =~ s/:(\d+)$// ) {
            $port = $1;
        }

        $base .= sprintf( '%s://%s', $scheme, $host );

        unless ( $port == 80 || $port == 443 ) {
            $base .= sprintf( ':%d', $port );
        }

        unless ( $path =~ /\/$/ ) {
            $path .= '/';
        }

        $base .= $path;
    }

    my $location = $ENV{SCRIPT_NAME} || '/';
    my $path = $ENV{PATH_INFO} || '/';
    $path =~ s/^($location)?\///;
    $path =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
    $path =~ s/^\///;

    $self->request->base($base);
    $self->request->path($path);
}

sub prepare_request {
    my ( $self, $object ) = @_;

    my $cgi;

    require CGI;

    if ( defined($object) && ref($object) ) {

        if ( $object->isa('Apache') ) {                   # MP 1.3
            $cgi = CGI->new($object);
        }

        elsif ( $object->isa('Apache::RequestRec') ) {    # MP 1.99
            $cgi = CGI->new($object);
        }

        elsif ( $object->isa('Apache2::RequestRec') ) {   # MP 2.00
            $cgi = CGI->new($object);
        }

        elsif ( $object->isa('CGI') ) {
            $cgi = $object;
        }

        else {
            my $type = ref($object);
            Carp::croak( qq/Invalid argument '$type'/ );
        }
    }

    $self->cgi( $cgi || CGI->new );
}

sub prepare_uploads {
    my $self = shift;

    my @uploads;

    for my $param ( $self->cgi->param ) {

        my @values = $self->cgi->param($param);

        next unless ref( $values[0] );

        for my $fh (@values) {

            next unless my $size = ( stat $fh )[7];

            my $info        = $self->cgi->uploadInfo($fh);
            my $tempname    = $self->cgi->tmpFileName($fh);
            my $type        = $info->{'Content-Type'};
            my $disposition = $info->{'Content-Disposition'};
            my $filename    = ( $disposition =~ / filename="([^;]*)"/ )[0];

            require CGI::Catalyst::Request::Upload;

            my $upload = CGI::Catalyst::Request::Upload->new(
                filename => $filename,
                size     => $size,
                tempname => $tempname,
                type     => $type
            );

            push( @uploads, $param, $upload );
        }
    }

    $self->request->upload(@uploads);
}

sub run { shift->handler(@_) }

sub stash {
    my $self = shift;

    if (@_) {
        my $stash = @_ > 1 ? {@_} : $_[0];
        while ( my ( $key, $val ) = each %$stash ) {
            $self->{stash}->{$key} = $val;
        }
    }

    return $self->{stash};
}

1;
