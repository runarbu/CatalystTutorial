package Catalyst::Plugin::Authenticate::FTP;

use strict;
use Carp ();
use Net::FTP;

our $VERSION = '0.1';

our $PARAMETERS = qw[
    username
    password
];

sub authenticate_ftp {
    my ( $c, $username, $password, $options ) = @_;

    unless ( @_ == 3 || ( @_ == 4 && ref($options) eq 'HASH' ) ) {
        Carp::croak('usage: $c->authenticate_ftp( $username, $password [, \%options ] )');
    }

    unless ( @_ == 4 ) {
        $options = {};
    }

    my $config = $c->config->{authenticate}->{ftp};

    my $host    = $options->{host}    || $config->{host}    || 'localhost';
    my $port    = $options->{port}    || $config->{port}    || 21;
    my $timeout = $options->{timeout} || $config->{timeout} || 60;


    my $connection = Net::FTP->new(
        Host    => $host,
        Port    => $port,
        Timeout => $timeout
    );

    unless ( defined $connection ) {
        $c->log->warn( qq/Failed to connect to '$host'. Reason: '$@'/ );
        return 0;
    }

    return 1 if $connection->login( $username, $password );
    return 0;
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Authenticate::FTP - Authenticate against a FTP service

=head1 SYNOPSIS

    use Catalyst qw[Authenticate::FTP];

    MyApp->config->{authenticate}->{ftp} = {
        host    => 'host.domain.com',
        port    => 21,
        timeout => 60
    };

    if ( $c->authenticate_ftp( $username, $password ) ) {
        # successful autentication
    }

=head1 DESCRIPTION

Authenticate against a FTP service.

=head1 SEE ALSO

L<Net::FTP>, L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
