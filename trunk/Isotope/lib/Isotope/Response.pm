package Isotope::Response;

use strict;
use warnings;
use base 'Isotope::Message';

use HTTP::Status qw[];
use URI          qw[];
use Moose        qw[has];

has 'status'         => ( isa       => 'Int',
                          is        => 'rw',
                          default   => 200,
                          required  => 1 );

has 'status_message' => ( isa       => 'Str',
                          is        => 'rw',
                          predicate => 'has_status_message' );

sub BUILD {
    my ( $self, $params ) = @_;

    unless ( $self->has_header('Date') ) {
        $self->headers->date( time() );
    }
}

sub etag {
    return shift->headers->etag(@_);
}

sub expires {
    return shift->headers->expires(@_);
}

sub last_modified {
    return shift->headers->last_modified(@_);
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

sub is_header_only {
    return 1 if $_[0]->request->method eq 'HEAD';
    return 1 if $_[0]->status =~ /^1\d\d|[23]04$/;
    return 0;
}

sub status_line {
    my $self   = shift;

    my $message;
    if ( $self->has_status_message ) {
        $message = $self->status_message;
    }
    else {
        $message = HTTP::Status::status_message( $self->status );
    }

    return sprintf( "%s %s", $self->status, $message );
}

sub redirect {
    my ( $self, $uri, $status ) = @_;
    $self->status( $status || 302 );
    $self->header( 'Location' => URI->new_abs( $uri, $self->request->base )->as_string );
}

1;

__END__

=head1 NAME

Isotope::Response - Isotope Response Class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 INHERITANCE

=over 2

=item L<Isotope::Object>

=over 2

=item L<Isotope::Message>

=over 2

=item L<Isotope::Response>

=back

=back

=back

=head1 METHODS

=over 4

=item etag

=item expires

=item is_info

Returns a boolean indicating whether or not C<status> is an I<Informational 1xx> status code.

=item is_success

Returns a boolean indicating whether or not C<status> is a I<Successful 2xx> status code.

=item is_redirect

Returns a boolean indicating whether or not C<status> is a I<Redirection 3xx> status code.

=item is_error

Returns a boolean indicating whether or not C<status> is an I<Error 4xx-5xx> status code.

=item is_header_only

Returns a boolean indicating whether or not only headers should be sent in response. 
Returns true if request method is I<HEAD> or C<status> is an I<Informational 1xx>,
I<No Content 204> or I<Not Modified 304>.

=item redirect ( $uri [ , $status ] )

=item status ( [ $status ] )

=item status_line

=item status_message ( [ $message ] )

=back

=head1 SEE ALSO

L<Isotope::Message>.

L<Isotope::Transaction>.

L<Isotope::Connection>.

L<Isotope::Request>.

=head1 AUTHOR

Christian Hansen C<ch@ngmedia.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify 
it under the same terms as Perl itself.

=cut
