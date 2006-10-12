package CGI::Catalyst::Request;

use strict;
use base 'Class::Accessor::Fast';

use HTTP::Headers;

__PACKAGE__->mk_accessors(
    qw/action address arguments body base cookies headers method 
       parameters path protocol secure uploads user/
);

*args   = \&arguments;
*params = \&parameters;

sub content_encoding { shift->headers->content_encoding(@_) }
sub content_length   { shift->headers->content_length(@_)   }
sub content_type     { shift->headers->content_type(@_)     }
sub header           { shift->headers->header(@_)           }
sub referer          { shift->headers->referer(@_)          }
sub user_agent       { shift->headers->user_agent(@_)       }

sub new {
    my $class = shift;
    my $self  = {
        arguments  => [],
        cookies    => {},
        headers    => HTTP::Headers->new,
        parameters => {},
        secure     => 0,
        uploads    => {}
    };

    return $class->SUPER::new($self);
}

=head1 NAME

Catalyst::CGI::Request - Request Class

=head1 SYNOPSIS


    $request = Catalyst::CGI::Request->new;
    $request->action;
    $request->address;
    $request->args;
    $request->arguments;
    $request->base;
    $request->body;
    $request->content_encoding;
    $request->content_length;
    $request->content_type;
    $request->cookie;
    $request->cookies;
    $request->header;
    $request->headers;
    $request->hostname;
    $request->method;
    $request->param;
    $request->params;
    $request->parameters;
    $request->path;
    $request->protocol;
    $request->referer;
    $request->secure;
    $request->upload;
    $request->uploads;
    $request->uri;
    $request->user;
    $request->user_agent;

See also L<Catalyst::CGI>.

=head1 DESCRIPTION

This is the Catalyst::CGI Request class, which provides a set of accessors to the
request data.

=head1 METHODS

=over 4

=item new

Constructor, does not take any arguments.

=item $request->action

Contains the requested action.

    print $myapp->request->action;

=item $request->address

Contains the remote address.

    print $myapp->request->address

=item $request->args

Shortcut for arguments

=item $request->arguments

Returns a reference to an array containing the arguments.

    print $myapp->request->arguments->[0];

=item $request->base

Contains the url base. This will always have a trailing slash.

=item $request->body

Contains the message body of the request unless Content-Type is
C<application/x-www-form-urlencoded> or C<multipart/form-data>.

    print $myapp->request->body

=item $request->content_encoding

Shortcut to $request->headers->content_encoding

=item $request->content_length

Shortcut to $request->headers->content_length

=item $request->content_type

Shortcut to $request->headers->content_type

=item $request->cookie

A convenient method to $request->cookies.

    $cookie  = $myapp->request->cookie('name');
    @cookies = $myapp->request->cookie;

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

=item $request->cookies

Returns a reference to a hash containing the cookies.

    print $myapp->request->cookies->{mycookie}->value;

=item $request->header

Shortcut to $request->headers->header

=item $request->headers

Returns an L<HTTP::Headers> object containing the headers.

    print $myapp->request->headers->header('X-Catalyst');

=item $request->hostname

Lookup the current users DNS hostname.

    print $myapp->request->hostname
    
=cut

sub hostname {
    my $self = shift;

    if ( @_ == 0 && not $self->{hostname} ) {
        require IO::Socket;
        $self->{hostname} = gethostbyaddr( IO::Socket::inet_aton( $self->address ), IO::Socket::AF_INET() );
    }

    if ( @_ == 1 ) {
        $self->{hostname} = shift;
    }

    return $self->{hostname};
}

=item $request->method

Contains the request method (C<GET>, C<POST>, C<HEAD>, etc).

    print $myapp->request->method;

=item $request->param

Get request parameters with a CGI.pm-compatible param method. This 
is a method for accessing parameters in $c->req->parameters.

    $value  = $myapp->request->param('foo');
    @values = $myapp->request->param('foo');
    @params = $myapp->request->param;

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

    if ( @_ > 1 ) {

        while ( my ( $field, $value ) = splice( @_, 0, 2 ) ) {
        
            next unless defined $field;

            if ( exists $self->parameters->{$field} ) {
                for ( $self->parameters->{$field} ) {
                    $_ = [$_] unless ref($_) eq "ARRAY";
                    push( @$_, $value );
                }
            }
            else {
                $self->parameters->{$field} = $value;
            }
        }
    }
}

=item $request->params

Shortcut for $request->parameters.

=item $request->parameters

Returns a reference to a hash containing parameters. Values can
be either a scalar or an arrayref containing scalars.

    print $myapp->request->parameters->{field};
    print $myapp->request->parameters->{field}->[0];

=item $request->path

Contains the path.

    print $myapp->request->path;

=item $request->protocol

Contains the protocol.

=item $request->referer

Shortcut to $request->headers->referer. Referring page.

=item $request->secure

Contains a boolean whether the communciation is secure.

=item $request->upload

A convenient method to $request->uploads.

    $upload  = $myapp->request->upload('field');
    @uploads = $myapp->request->upload('field');
    @fields  = $myapp->request->upload;

    for my $upload ( $myapp->request->upload('field') ) {
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

=item $request->uploads

Returns a reference to a hash containing uploads. Values can be either a
hashref or a arrayref containing C<Catalyst::CGI::Request::Upload> objects.

    my $upload = $myapp->request->uploads->{field};
    my $upload = $myapp->request->uploads->{field}->[0];

=item $request->uri

Shortcut for C<< $request->base . $request->path >>.

=cut

sub uri {
    my $self = shift;
    my $path = shift || $self->path || '';
    return $self->base . $path;
}

=item $request->user

Contains the user name of user if authentication check was successful.

=item $request->user_agent

Shortcut to $request->headers->user_agent. User Agent version string.

=back

=head1 AUTHOR

Sebastian Riedel, C<sri@cpan.org>
Marcus Ramberg, C<mramberg@cpan.org>
Christian Hansen, C<ch@ngmedia.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
