package Catalyst::Plugin::Compress::Gzip;

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

    unless ( index( $accept, "gzip" ) >= 0 ) {
        return $c->NEXT::finalize;
    }

    $c->response->body( Compress::Zlib::memGzip( $c->response->body ) );
    $c->response->content_length( length( $c->response->body ) );
    $c->response->content_encoding('gzip');
    $c->response->headers->push_header( 'Vary', 'Accept-Encoding' );

    $c->NEXT::finalize;
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Compress::Gzip - Gzip response

=head1 SYNOPSIS

    use Catalyst qw[Compress::Gzip];


=head1 DESCRIPTION

Gzip compress response if client supports it.

=head1 SEE ALSO

L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
