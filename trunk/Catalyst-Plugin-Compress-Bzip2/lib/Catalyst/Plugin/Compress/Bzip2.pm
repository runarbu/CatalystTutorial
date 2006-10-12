package Catalyst::Plugin::Compress::Bzip2;

use strict;

use Compress::Bzip2 2.0 ();

our $VERSION = '0.02';

sub finalize {
    my $c = shift;

    if ( $c->response->content_encoding ) {
        return $c->NEXT::finalize;
    }

    unless ( $c->response->body ) {
        return $c->NEXT::finalize;
    }

    unless ( $c->response->status == 200 ) {
        return $c->NEXT::finalize;
    }

    unless ( $c->response->content_type =~ /^text|xml$|javascript$/ ) {
        return $c->NEXT::finalize;
    }

    my $accept = $c->request->header('Accept-Encoding') || '';

    unless ( index( $accept, "bzip2" ) >= 0 ) {
        return $c->NEXT::finalize;
    }

    $c->response->body( Compress::Bzip2::memBzip( $c->response->body ) );
    $c->response->content_length( length( $c->response->body ) );
    $c->response->content_encoding('bzip2');
    $c->response->headers->push_header( 'Vary', 'Accept-Encoding' );

    $c->NEXT::finalize;
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Compress::Bzip2 - Bzip2 response

=head1 SYNOPSIS

    use Catalyst qw[Compress::Bzip2];


=head1 DESCRIPTION

Bzip2 compress response if client supports it.

=head1 SEE ALSO

L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
