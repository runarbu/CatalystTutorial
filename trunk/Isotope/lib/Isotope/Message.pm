package Isotope::Message;

use strict;
use warnings;
use base 'Isotope::Object';

use Isotope::Headers qw[];
use Moose            qw[has];

has 'content'     => ( isa       => 'Ref',
                       reader    => 'get_content',
                       writer    => 'set_content',
                       predicate => 'has_content' );

has 'headers'     => ( isa       => 'Isotope::Headers',
                       is        => 'rw',
                       coerce    => 1,
                       required  => 1,
                       default   => sub { Isotope::Headers->new } );

has 'cookie'      => ( isa       => 'HashRef',
                       reader    => 'get_cookie',
                       writer    => 'set_cookie',
                       predicate => 'has_cookie',
                       required  => 1,
                       default   => sub { {} } );

has 'protocol'    => ( isa       => 'Protocol',
                       is        => 'rw',
                       predicate => 'has_protocol' );

has 'transaction' => ( isa       => 'Isotope::Transaction',
                       is        => 'rw',
                       weak_ref  => 1 );


# XXX Fix me
sub cookie {
    my $self   = shift;
    my $cookie = $self->get_cookie;
}

sub content {
    my $self    = shift;
    my $content = $self->get_content;

    if ( @_ ) {
        $self->set_content( defined $_[0] ? ref $_[0] ? shift : \( my $c = shift ) : shift );
    }
    
    return unless defined wantarray;

    if ( ref $content eq 'SCALAR' ) {
        $content = $$content;
    }

    return $content;
}

*content_ref = \&get_content;

sub header {
    return shift->headers->header(@_);
}

sub has_header {
    return shift->headers->has(@_);
}

sub content_encoding {
    return shift->headers->content_encoding(@_);
}

sub content_language {
    return shift->headers->content_language(@_);
}

sub content_length {
    return shift->headers->content_length(@_);
}

sub content_type {
    return shift->headers->content_type(@_);
}

sub connection {
    return $_[0]->transaction->connection;
}

sub request {
    return $_[0]->transaction->request;
}

sub response {
    return $_[0]->transaction->response;
}

sub protocol_version {
    my $self = shift;

    if ( $self->protocol && $self->protocol =~ /^HTTP\/([0-9]+)\.([0-9]+)$/ ) {
        return $1 * 1000 + $2;
    }

    return 0 * 1000 + 9;
}

1;

=head1 NAME

Isotope::Message - Isotope Message Class

=head1 SYNOPSIS

=head1 DESCRIPTION

This is a base class for L<Isotope::Request> and L<Isotope::Response>.

=head1 METHODS

=over 4

=item new

=item content

    $message->content( $string      );
    $message->content( \$string     );
    $message->content( \*FILEHANDLE );
    $message->content( $io_handle   );

=item content_ref

    $content = $message->content_ref;

=item has_content

=item content_encoding

=item content_language

=item content_length

=item content_type

=item header

=item headers

=item has_header

=item protocol

=item protocol_version

=item transaction

=item connection

=item request

=item response

=back

=head1 SEE ALSO

L<Isotope::Transaction>.

L<Isotope::Connection>.

L<Isotope::Request>.

L<Isotope::Response>.

L<Isotope::Headers>.

=head1 AUTHOR

Christian Hansen C<ch@ngmedia.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify 
it under the same terms as Perl itself.

=cut
