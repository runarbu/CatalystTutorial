package Isotope::Connection;

use strict;
use warnings;
use base 'Isotope::Object';

use Moose qw[has];

has 'aborted'      => ( isa       => 'Bool',
                        is        => 'rw' );

has 'local_host'   => ( isa       => 'Str',
                        is        => 'rw' );

has 'local_ip'     => ( isa       => 'Str',
                        is        => 'rw' );

has 'local_port'   => ( isa       => 'Int',
                        is        => 'rw' );

has 'remote_host'  => ( isa       => 'Str',
                        is        => 'rw' );

has 'remote_ip'    => ( isa       => 'Str',
                        is        => 'rw' );

has 'remote_port'  => ( isa       => 'Int',
                        is        => 'rw' );

has 'transaction'  => ( isa       => 'Isotope::Transaction',
                        is        => 'rw',
                        weak_ref  => 1 );

has 'transactions' => ( isa       => 'Int',
                        is        => 'rw',
                        default   => 0 );

has 'secure'       => ( isa       => 'Bool',
                        is        => 'rw',
                        default   => 0 );

has 'user'         => ( isa       => 'Str',
                        is        => 'rw' );

sub keepalive {
    my $self = shift;

    my $version = $self->request->protocol_version;

    if ( $self->response->has_header('Connection') ) {
        return 0 if index( lc $self->response->header('Connection'), 'close' ) >= 0;
    }

    if ( $version >= 1001 ) {
        return 1 unless $self->request->has_header('Connection');
        return 1 unless $self->request->header('Connection') =~ /close/i;
        return 0;
    }

    if ( $version == 1000 ) {
        return 0 unless $self->response->has_header('Connection');
        return 0 unless $self->response->header('Connection') =~ /Keep-Alive/i;
        return 1 if $self->response->is_header_only;
        return 0 unless $self->response->content_length;
        return 1;
    }

    return 0;
}

sub request {
    return $_[0]->transaction->request;
}

sub response {
    return $_[0]->transaction->response;
}

1;

__END__

=head1 NAME

Isotope::Connection - Isotope Connection Class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item local_host

=item local_ip

=item local_port

=item remote_host

=item remote_ip

=item remote_port

=item secure

Returns a boolean indicating whether or not transaction is over a secure transport.

=item user

=item transactions

=item transaction

=item request

=item response

=back

=head1 SEE ALSO

L<Isotope::Message>.

L<Isotope::Request>.

L<Isotope::Response>.

L<Isotope::Transaction>.

=head1 AUTHOR

Christian Hansen C<ch@ngmedia.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

