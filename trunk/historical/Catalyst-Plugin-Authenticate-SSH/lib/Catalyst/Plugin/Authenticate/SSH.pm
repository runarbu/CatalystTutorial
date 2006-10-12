package Catalyst::Plugin::Authenticate::SSH;

use strict;
use Carp ();
use Net::SSH::Perl;

our $VERSION = '0.1';

our $PARAMETERS = qw[
    username
    password
];

sub authenticate_ssh {
    my ( $c, $username, $password, $options ) = @_;

    unless ( @_ == 3 || ( @_ == 4 && ref($options) eq 'HASH' ) ) {
        Carp::croak('usage: $c->authenticate_ssh( $username, $password [, \%options ] )');
    }

    unless ( @_ == 4 ) {
        $options = {};
    }

    my $config = $c->config->{authenticate}->{ssh};

    my $host     = $options->{host}     || $config->{host}     || 'localhost';
    my $port     = $options->{port}     || $config->{port}     || 22;
    my $protocol = $options->{protocol} || $config->{protocol} || 2;
    my $cipher   = $options->{cipher}   || $config->{cipher}   || undef;

    my %params = (
        port     => $port,
        protocol => $protocol,
        cipher   => $cipher
    );

    my $connection;

    eval { $connection = Net::SSH::Perl->new( $host, %params ) };

    if ( my $error = $@ ) {
        chomp $error;
        $c->log->warn(qq/Failed to connect to '$host'. Reason: '$@'/);
        return 0;
    }

    eval { $connection->login( $username, $password ) };

    if ( my $error = $@ ) {
        chomp $error;
        $c->log->debug(qq/Failed to authenticate user '$username'. Reason: '$error'/);
        return 0;
    }

    return 1;
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Authenticate::SSH - Authenticate against a SSH service

=head1 SYNOPSIS

    use Catalyst qw[Authenticate::SSH];

    MyApp->config->{authenticate}->{ssh} = {
        host    => 'host.domain.com',
    };

    if ( $c->authenticate_ssh( $username, $password ) ) {
        # successful autentication
    }

=head1 DESCRIPTION

Authenticate against a SSH service.

=head1 SEE ALSO

L<Net::SSH::Perl>, L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
