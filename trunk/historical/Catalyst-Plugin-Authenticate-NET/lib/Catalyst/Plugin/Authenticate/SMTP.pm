package Catalyst::Plugin::Authenticate::SMTP;

use strict;
use Carp ();
use Net::SMTP;

our $VERSION = '0.1';

our $PARAMETERS = qw[
    username
    password
];

sub authenticate_smtp {
    my ( $c, $username, $password, $options ) = @_;

    unless ( @_ == 3 || ( @_ == 4 && ref($options) eq 'HASH' ) ) {
        Carp::croak('usage: $c->authenticate_smtp( $username, $password [, \%options ] )');
    }

    unless ( @_ == 4 ) {
        $options = {};
    }

    my $config = $c->config->{authenticate}->{smtp};

    my $host    = $options->{host}    || $config->{host}    || 'localhost';
    my $port    = $options->{port}    || $config->{port}    || 25;
    my $timeout = $options->{timeout} || $config->{timeout} || 60;


    my $connection = Net::SMTP->new(
        Host    => $host,
        Port    => $port,
        Timeout => $timeout
    );

    unless ( defined $connection ) {
        $c->log->warn( qq/Failed to connect to '$host'. Reason: '$@'/ );
        return 0;
    }

    return 1 if $connection->auth( $username, $password );
    return 0;
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Authenticate::SMTP - Authenticate against a SMTP service

=head1 SYNOPSIS

    use Catalyst qw[Authenticate::SMTP];

    MyApp->config->{authenticate}->{smtp} = {
        host    => 'host.domain.com',
        port    => 110,
        timeout => 10
    };

    if ( $c->authenticate_smtp( $username, $password ) ) {
        # successful autentication
    }

=head1 DESCRIPTION

Authenticate against a SMTP service.

=head1 SEE ALSO

L<Net::SMTP>, L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
