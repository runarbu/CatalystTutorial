package Catalyst::Plugin::Request::ForwardedFor;

use strict;
use base 'Class::Data::Inheritable';

use Carp ();
use Net::Subnets;

our $VERSION = '0.01';

__PACKAGE__->mk_classdata( '_forwarded_for' => Net::Subnets->new );

sub prepare_headers {
    my $c = shift;

    $c->NEXT::prepare_headers(@_);

    if ( my $address = $c->request->header('X-Forwarded-For') ) {

        if ( $c->_forwarded_for->check( \$c->request->address ) ) {
            $c->request->address($address);
        }
    }
}

sub setup {
    my $self = shift;

    my $subnets = $self->config->{subnets} || [ '127.0.0.1/32' ];

    unless ( ref($subnets) && ref($subnets) eq 'ARRAY' ) {
        Carp::croak( qq/MyApp->config( subnets => \@CIDR_ADDRESSES )/ );
    }


    # Net::Subnets offers no validation, so we better do it.

    for my $cidr ( @{ $subnets } ) {

        my @parts = $cidr =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)\/(\d+)$/;

        unless ( 5 == @parts ) {
            Carp::croak( qq/Invalid CIDR address '$cidr'/ );
        }

        unless ( 4 == grep { $_ <= 255 } @parts[0..3] ) {
            Carp::croak( qq/Invalid octet in CIDR address '$cidr'/ );
        }

        unless ( $parts[4] <= 32 ) {
            Carp::croak( qq/Invalid CIDR prefix '$parts[4]' in address '$cidr'/ );
        }
    }

    $self->_forwarded_for->subnets($subnets);

    return $self->NEXT::setup(@_);
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Request::ForwardedFor - X-Forwarded-For

=head1 SYNOPSIS

    use Catalyst qw[Request::ForwardedFor];

    MyApp->config( subnets => [ '192.168.0.0/24', '127.0.0.1/32' ] );


=head1 DESCRIPTION

C<< X-Forwarded-For >>

=head1 OVERLOADED METHODS

=over 4

=item prepare_headers

=item setup

=back

=head1 SEE ALSO

L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as perl itself.

=cut
