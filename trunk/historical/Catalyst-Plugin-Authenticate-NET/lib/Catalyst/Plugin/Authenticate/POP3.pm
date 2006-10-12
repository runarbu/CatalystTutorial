package Catalyst::Plugin::Authenticate::POP3;

use strict;
use Carp ();
use Net::POP3;

our $VERSION = '0.1';

our $PARAMETERS = qw[
    username
    password
];

sub authenticate_pop3 {
    my ( $c, $username, $password, $options ) = @_;

    unless ( @_ == 3 || ( @_ == 4 && ref($options) eq 'HASH' ) ) {
        Carp::croak('usage: $c->authenticate_pop3( $username, $password [, \%options ] )');
    }

    unless ( @_ == 4 ) {
        $options = {};
    }

    my $config = $c->config->{authenticate}->{pop3};

    my $host    = $options->{host}    || $config->{host}    || 'localhost';
    my $port    = $options->{port}    || $config->{port}    || 110;
    my $timeout = $options->{timeout} || $config->{timeout} || 60;
    my $method  = $options->{method}  || $config->{method}  || 'plain';


    my $connection = Net::POP3->new(
        Host    => $host,
        Port    => $port,
        Timeout => $timeout
    );

    unless ( defined $connection ) {
        $c->log->warn( qq/Failed to connect to '$host'. Reason: '$@'/ );
        return 0;
    }

    if ( $method eq 'plain' ) {
        return 1 if $connection->login( $username, $password );
    }

    if ( $method eq 'sasl' ) {
        return 1 if $connection->auth( $username, $password );
    }

    if ( $method eq 'apop' ) {
        return 1 if $connection->apop( $username, $password );
    }

    return 0;
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Authenticate::POP3 - Authenticate against a POP3 service

=head1 SYNOPSIS

    use Catalyst qw[Authenticate::POP3];

    MyApp->config->{authenticate}->{pop3} = {
        host    => 'host.domain.com',
        port    => 110,
        timeout => 10,
        method  => 'apop' # plain, apop or sasl
    };

    if ( $c->authenticate_pop3( $username, $password ) ) {
        # successful autentication
    }

=head1 DESCRIPTION

Authenticate against a POP3 service.

=head1 SEE ALSO

L<Net::POP3>, L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
