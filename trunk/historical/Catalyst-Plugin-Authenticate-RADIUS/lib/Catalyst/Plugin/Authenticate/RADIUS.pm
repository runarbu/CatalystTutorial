package Catalyst::Plugin::Authenticate::RADIUS;

use strict;
use Carp ();
use Authen::Radius;

our $VERSION = '0.1';

our $PARAMETERS = qw[
    username
    password
];

sub authenticate_radius {
    my ( $c, $username, $password, $options ) = @_;

    unless ( @_ == 3 || ( @_ == 4 && ref($options) eq 'HASH' ) ) {
        Carp::croak('usage: $c->authenticate_radius( $username, $password [, \%options ] )');
    }

    unless ( @_ == 4 ) {
        $options = {};
    }

    my $config = $c->config->{authenticate}->{radius};

    my $host    = $options->{host}    || $config->{host}    || 'localhost';
    my $port    = $options->{port}    || $config->{port}    || 1645;
    my $timeout = $options->{timeout} || $config->{timeout} || 60;
    my $secret  = $options->{secret}  || $config->{secret}  || undef;


    my $connection = Authen::Radius->new(
        Host    => "$host:$port",
        Secret  => $secret,
        Timeout => $timeout
    );

    unless ( defined $connection ) {
        my $error = Authen::Radius::strerror();
        $c->log->warn( qq/Failed to connect to '$host'. Reason: '$error'/ );
        return 0;
    }

    return 1 if $connection->check_pwd( $username, $password );
    return 0;
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Authenticate::RADIUS - Authenticate against a RADIUS service

=head1 SYNOPSIS

    use Catalyst qw[Authenticate::RADIUS];

    MyApp->config->{authenticate}->{radius} = {
        host    => 'host.domain.com',
        port    => 1645,
        timeout => 60,
        secret  => 'xxxxx'
    };

    if ( $c->authenticate_radius( $username, $password ) ) {
        # successful autentication
    }

=head1 DESCRIPTION

Authenticate against a RADIUS service.

=head1 SEE ALSO

L<Authen::Radius>, L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
