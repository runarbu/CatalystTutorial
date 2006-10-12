package Catalyst::Plugin::Compress::Deflate;

use strict;

use Compress::Zlib ();

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

    unless ( index( $accept, "deflate" ) >= 0 ) {
        return $c->NEXT::finalize;
    }

    my ( $d, $out, $status, $deflated );

    ( $d, $status ) = Compress::Zlib::deflateInit(
        -WindowBits => -Compress::Zlib::MAX_WBITS(),
    );

    unless ( $status == Compress::Zlib::Z_OK() ) {
        die("Cannot create a deflation stream. Error: $status");
    }

    ( $out, $status ) = $d->deflate( $c->response->body );

    unless ( $status == Compress::Zlib::Z_OK() ) {
        die("Deflation failed. Error: $status");
    }

    $deflated .= $out;

    ( $out, $status ) = $d->flush;

    unless ( $status == Compress::Zlib::Z_OK() ) {
        die("Deflation failed. Error: $status");
    }

    $deflated .= $out;

    $c->response->body($deflated);
    $c->response->content_length( length($deflated) );
    $c->response->content_encoding('deflate');
    $c->response->headers->push_header( 'Vary', 'Accept-Encoding' );

    $c->NEXT::finalize;
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Compress::Deflate - Deflate response

=head1 SYNOPSIS

    use Catalyst qw[Compress::Deflate];


=head1 DESCRIPTION

Deflate compress response if client supports it.

=head1 SEE ALSO

L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
