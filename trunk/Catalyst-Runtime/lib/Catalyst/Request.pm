package Catalyst::Request;

use strict;
use base 'Class::Accessor::Fast';

use IO::Socket qw[AF_INET inet_aton];
use Carp;
use utf8;
use URI::QueryParam;

__PACKAGE__->mk_accessors(
    qw/action address arguments cookies headers match method
      protocol query_parameters secure captures uri user/
);

*args         = \&arguments;
*body_params  = \&body_parameters;
*input        = \&body;
*params       = \&parameters;
*query_params = \&query_parameters;
*path_info    = \&path;
*snippets     = \&captures;

sub content_encoding { shift->headers->content_encoding(@_) }
sub content_length   { shift->headers->content_length(@_) }
sub content_type     { shift->headers->content_type(@_) }
sub header           { shift->headers->header(@_) }
sub referer          { shift->headers->referer(@_) }
sub user_agent       { shift->headers->user_agent(@_) }

=head1 NAME

Catalyst::Request - provides information about the current client request

=head1 SYNOPSIS

    $req = $c->request;
    $req->action;
    $req->address;
    $req->arguments;
    $req->args;
    $req->base;
    $req->body;
    $req->body_parameters;
    $req->content_encoding;
    $req->content_length;
    $req->content_type;
    $req->cookie;
    $req->cookies;
    $req->header;
    $req->headers;
    $req->hostname;
    $req->input;
    $req->match;
    $req->method;
    $req->param;
    $req->parameters;
    $req->params;
    $req->path;
    $req->protocol;
    $req->query_parameters;
    $req->read;
    $req->referer;
    $req->secure;
    $req->captures; # previously knows as snippets
    $req->upload;
    $req->uploads;
    $req->uri;
    $req->user;
    $req->user_agent;

See also L<Catalyst>, L<Catalyst::Request::Upload>.

=head1 DESCRIPTION

This is the Catalyst Request class, which provides an interface to data for the
current client request. The request object is prepared by L<Catalyst::Engine>,
thus hiding the details of the particular engine implementation.

=head1 METHODS

=head2 $req->action

Returns the requested action as a L<Catalyst::Action> object.

=head2 $req->address

Returns the IP address of the client.

=head2 $req->arguments

Returns a reference to an array containing the arguments.

    print $c->request->arguments->[0];

For example, if your action was

	package MyApp::C::Foo;
	
	sub moose : Local {
		...
	}

and the URI for the request was C<http://.../foo/moose/bah>, the string C<bah>
would be the first and only argument.

=head2 $req->args

Shortcut for arguments.

=head2 $req->base

Contains the URI base. This will always have a trailing slash.

If your application was queried with the URI
C<http://localhost:3000/some/path> then C<base> is C<http://localhost:3000/>.

=cut

sub base {
    my ( $self, $base ) = @_;

    return $self->{base} unless $base;

    $self->{base} = $base;

    # set the value in path for backwards-compat
    if ( $self->uri ) {
        $self->path;
    }

    return $self->{base};
}

=head2 $req->body

Returns the message body of the request, unless Content-Type is
C<application/x-www-form-urlencoded> or C<multipart/form-data>.

=cut

sub body {
    my ( $self, $body ) = @_;
    $self->{_context}->prepare_body;
    return $self->{_body}->body;
}

=head2 $req->body_parameters

Returns a reference to a hash containing body (POST) parameters. Values can
be either a scalar or an arrayref containing scalars.

    print $c->request->body_parameters->{field};
    print $c->request->body_parameters->{field}->[0];

These are the parameters from the POST part of the request, if any.
    
=head2 $req->body_params

Shortcut for body_parameters.

=cut

sub body_parameters {
    my ( $self, $params ) = @_;
    $self->{_context}->prepare_body;
    $self->{body_parameters} = $params if $params;
    return $self->{body_parameters};
}

=head2 $req->content_encoding

Shortcut for $req->headers->content_encoding.

=head2 $req->content_length

Shortcut for $req->headers->content_length.

=head2 $req->content_type

Shortcut for $req->headers->content_type.

=head2 $req->cookie

A convenient method to access $req->cookies.

    $cookie  = $c->request->cookie('name');
    @cookies = $c->request->cookie;

=cut

sub cookie {
    my $self = shift;

    if ( @_ == 0 ) {
        return keys %{ $self->cookies };
    }

    if ( @_ == 1 ) {

        my $name = shift;

        unless ( exists $self->cookies->{$name} ) {
            return undef;
        }

        return $self->cookies->{$name};
    }
}

=head2 $req->cookies

Returns a reference to a hash containing the cookies.

    print $c->request->cookies->{mycookie}->value;

The cookies in the hash are indexed by name, and the values are L<CGI::Cookie>
objects.

=head2 $req->header

Shortcut for $req->headers->header.

=head2 $req->headers

Returns an L<HTTP::Headers> object containing the headers for the current request.

    print $c->request->headers->header('X-Catalyst');

=head2 $req->hostname

Returns the hostname of the client.
    
=cut

sub hostname {
    my $self = shift;

    if ( @_ == 0 && not $self->{hostname} ) {
        $self->{hostname} =
          gethostbyaddr( inet_aton( $self->address ), AF_INET );
    }

    if ( @_ == 1 ) {
        $self->{hostname} = shift;
    }

    return $self->{hostname};
}

=head2 $req->input

Alias for $req->body.

=head2 $req->match

This contains the matching part of a Regex action. Otherwise
it returns the same as 'action', except for default actions,
which return an empty string.

=head2 $req->method

Contains the request method (C<GET>, C<POST>, C<HEAD>, etc).

=head2 $req->param

Returns GET and POST parameters with a CGI.pm-compatible param method. This 
is an alternative method for accessing parameters in $c->req->parameters.

    $value  = $c->request->param( 'foo' );
    @values = $c->request->param( 'foo' );
    @params = $c->request->param;

Like L<CGI>, and B<unlike> earlier versions of Catalyst, passing multiple
arguments to this method, like this:

	$c->request->param( 'foo', 'bar', 'gorch', 'quxx' );

will set the parameter C<foo> to the multiple values C<bar>, C<gorch> and
C<quxx>. Previously this would have added C<bar> as another value to C<foo>
(creating it if it didn't exist before), and C<quxx> as another value for
C<gorch>.

=cut

sub param {
    my $self = shift;

    if ( @_ == 0 ) {
        return keys %{ $self->parameters };
    }

    if ( @_ == 1 ) {

        my $param = shift;

        unless ( exists $self->parameters->{$param} ) {
            return wantarray ? () : undef;
        }

        if ( ref $self->parameters->{$param} eq 'ARRAY' ) {
            return (wantarray)
              ? @{ $self->parameters->{$param} }
              : $self->parameters->{$param}->[0];
        }
        else {
            return (wantarray)
              ? ( $self->parameters->{$param} )
              : $self->parameters->{$param};
        }
    }
    elsif ( @_ > 1 ) {
        my $field = shift;
        $self->parameters->{$field} = [@_];
    }
}

=head2 $req->parameters

Returns a reference to a hash containing GET and POST parameters. Values can
be either a scalar or an arrayref containing scalars.

    print $c->request->parameters->{field};
    print $c->request->parameters->{field}->[0];

This is the combination of C<query_parameters> and C<body_parameters>.

=head2 $req->params

Shortcut for $req->parameters.

=cut

sub parameters {
    my ( $self, $params ) = @_;
    $self->{_context}->prepare_body;
    if ( $params ) {
        if ( ref $params ) {
            $self->{parameters} = $params;
        }
        else {
            $self->{_context}->log->warn( 
                "Attempt to retrieve '$params' with req->params(), " .
                "you probably meant to call req->param('$params')" );
        }
    }
    return $self->{parameters};
}

=head2 $req->path

Returns the path, i.e. the part of the URI after $req->base, for the current request.

=head2 $req->path_info

Alias for path, added for compability with L<CGI>.

=cut

sub path {
    my ( $self, $params ) = @_;

    if ($params) {
        $self->uri->path($params);
    }
    else {
        return $self->{path} if $self->{path};
    }

    my $path     = $self->uri->path;
    my $location = $self->base->path;
    $path =~ s/^(\Q$location\E)?//;
    $path =~ s/^\///;
    $self->{path} = $path;

    return $path;
}

=head2 $req->protocol

Returns the protocol (HTTP/1.0 or HTTP/1.1) used for the current request.

=head2 $req->query_parameters

Returns a reference to a hash containing query string (GET) parameters. Values can
be either a scalar or an arrayref containing scalars.

    print $c->request->query_parameters->{field};
    print $c->request->query_parameters->{field}->[0];
    
=head2 $req->read( [$maxlength] )

Reads a chunk of data from the request body. This method is intended to be
used in a while loop, reading $maxlength bytes on every call. $maxlength
defaults to the size of the request if not specified.

You have to set MyApp->config->{parse_on_demand} to use this directly.

=cut

sub read { shift->{_context}->read(@_); }

=head2 $req->referer

Shortcut for $req->headers->referer. Returns the referring page.

=head2 $req->secure

Returns true or false, indicating whether the connection is secure (https).

=head2 $req->captures

Returns a reference to an array containing regex captures.

    my @captures = @{ $c->request->captures };

=head2 $req->snippets

C<captures> used to be called snippets. This is still available for backwoards
compatibility, but is considered deprecated.

=head2 $req->upload

A convenient method to access $req->uploads.

    $upload  = $c->request->upload('field');
    @uploads = $c->request->upload('field');
    @fields  = $c->request->upload;

    for my $upload ( $c->request->upload('field') ) {
        print $upload->filename;
    }

=cut

sub upload {
    my $self = shift;

    if ( @_ == 0 ) {
        return keys %{ $self->uploads };
    }

    if ( @_ == 1 ) {

        my $upload = shift;

        unless ( exists $self->uploads->{$upload} ) {
            return wantarray ? () : undef;
        }

        if ( ref $self->uploads->{$upload} eq 'ARRAY' ) {
            return (wantarray)
              ? @{ $self->uploads->{$upload} }
              : $self->uploads->{$upload}->[0];
        }
        else {
            return (wantarray)
              ? ( $self->uploads->{$upload} )
              : $self->uploads->{$upload};
        }
    }

    if ( @_ > 1 ) {

        while ( my ( $field, $upload ) = splice( @_, 0, 2 ) ) {

            if ( exists $self->uploads->{$field} ) {
                for ( $self->uploads->{$field} ) {
                    $_ = [$_] unless ref($_) eq "ARRAY";
                    push( @$_, $upload );
                }
            }
            else {
                $self->uploads->{$field} = $upload;
            }
        }
    }
}

=head2 $req->uploads

Returns a reference to a hash containing uploads. Values can be either a
hashref or a arrayref containing L<Catalyst::Request::Upload> objects.

    my $upload = $c->request->uploads->{field};
    my $upload = $c->request->uploads->{field}->[0];

=cut

sub uploads {
    my ( $self, $uploads ) = @_;
    $self->{_context}->prepare_body;
    $self->{uploads} = $uploads if $uploads;
    return $self->{uploads};
}

=head2 $req->uri

Returns a URI object for the current request. Stringifies to the URI text.

=head2 $req->uri_with( { key => 'value' } );

Returns a rewritten URI object for the current request. Key/value pairs
passed in will override existing parameters. Unmodified pairs will be
preserved.

=cut

sub uri_with {
    my( $self, $args ) = @_;
    
    carp( 'No arguments passed to uri_with()' ) unless $args;

    for my $value ( values %$args ) {
        for ( ref $value eq 'ARRAY' ? @$value : $value ) {
            $_ = "$_";
            utf8::encode( $_ );
        }
    };
    
    my $uri = $self->uri->clone;
    
    $uri->query_form( {
        %{ $uri->query_form_hash },
        %$args
    } );
    return $uri;
}

=head2 $req->user

Returns the currently logged in user. Deprecated. The method recommended for
newer plugins is $c->user.

=head2 $req->user_agent

Shortcut to $req->headers->user_agent. Returns the user agent (browser)
version string.

=head1 AUTHORS

Sebastian Riedel, C<sri@cpan.org>

Marcus Ramberg, C<mramberg@cpan.org>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
