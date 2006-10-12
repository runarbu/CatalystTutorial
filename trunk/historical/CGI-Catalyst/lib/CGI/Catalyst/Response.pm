package CGI::Catalyst::Response;

use strict;
use base 'Class::Accessor::Fast';

use HTTP::Headers;

__PACKAGE__->mk_accessors(qw/cookies body headers location status/);

sub content_encoding { shift->headers->content_encoding(@_) }
sub content_length   { shift->headers->content_length(@_)   }
sub content_type     { shift->headers->content_type(@_)     }
sub header           { shift->headers->header(@_)           }

sub new {
    my $class = shift;
    my $self  = {
        body    => '',
        cookies => {},
        headers => HTTP::Headers->new( 'Content-Length' => 0 ),
        status  => 200
    };

    return $class->SUPER::new($self);
}

=head1 NAME

CGI::Catalyst::Response - Response Class

=head1 SYNOPSIS

    $response = CGI::Catalyst::Response->new;
    $response->body;
    $response->content_encoding;
    $response->content_length;
    $response->content_type;
    $response->cookies;
    $response->header;
    $response->headers;
    $response->redirect;
    $response->status;

See also L<CGI::Catalyst>.

=head1 DESCRIPTION

This is the CGI::Catalyst Response class, which provides a set of accessors
to response data.

=head1 METHODS

=over 4

=item new

Constructor, does not take any arguments.

=item $response->body($text)

    $myapp->response->body('CGI::Catalyst rocks!');

Contains the final output.

=item $response->content_encoding

Shortcut to $response->headers->content_encoding

=item $response->content_length

Shortcut to $response->headers->content_length

=item $response->content_type

Shortcut to $response->headers->content_type

=item $response->cookies

Returns a reference to a hash containing the cookies to be set.

    $myapp->response->cookies->{foo} = { value => '123' };

=item $response->header

Shortcut to $response->headers->header

=item $response->headers

Returns a L<HTTP::Headers> object containing the headers.

    $myapp->response->headers->header( 'X-CGI-Catalyst' => $CGI::Catalyst::VERSION );

=item $response->redirect( $url [, $status ] )

Contains a location to redirect to.

    $myapp->response->redirect( 'http://slashdot.org' );
    $myapp->response->redirect( 'http://slashdot.org', 307 );

=cut

sub redirect {
    my $self = shift;
    
    if ( @_ ) {
        my $location = shift;
        my $status   = shift || 302;

        $self->location($location);
        $self->status($status);
    }

    return $self->location;
}

=item status

Contains the HTTP status.

    $myapp->response->status(404);

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
