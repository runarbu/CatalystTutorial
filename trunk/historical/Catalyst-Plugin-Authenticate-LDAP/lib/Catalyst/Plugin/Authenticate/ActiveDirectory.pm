package Catalyst::Plugin::Authenticate::ActiveDirectory;

use strict;
use Carp ();
use Net::LDAP;

our $VERSION = '0.1';

our $PARAMETERS = qw[
    username
    password
];

sub authenticate_ad {
    my ( $c, $username, $password, $options ) = @_;

    unless ( @_ == 3 || ( @_ == 4 && ref($options) eq 'HASH' ) ) {
        Carp::croak('usage: $c->authenticate_ad( $username, $password [, \%options ] )');
    }

    unless ( @_ == 4 ) {
        $options = {};
    }

    my $config = $c->config->{authenticate}->{ad};

    # connection
    my $host      = $options->{host}      || $config->{host}       || 'localhost';
    my $port      = $options->{port}      || $config->{port}       || 389;
    my $timeout   = $options->{timeout}   || $config->{timeout}    || 60;
    my $principal = $options->{principal} || $config->{principal}  || undef;

    my $connection = Net::LDAP->new( $host,
        Port    => $port,
        Timeout => $timeout
    );

    unless ( defined $connection ) {
        $c->log->warn(qq/Failed to connect to '$host'. Reason: '$@'/);
        return 0;
    }

    my $user    = sprintf( '%s@%s', $username, $principal );
    my $message = $connection->bind( $user, password => $password );

    if ( $message->is_error ) {
        my $error = $message->error;
        $c->log->debug(qq/Failed to bind with user principal '$user'. Reason: '$error'/);
        return 0;
    }

    return 1;
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Authenticate::ActiveDirectory - Authenticate against Active Directory

=head1 SYNOPSIS

    use Catalyst qw[Authenticate::ActiveDirectory];

    MyApp->config->{authenticate}->{ad} = {
        host      => 'ad.company.com',
        principal => 'company.com'
    };

    if ( $c->authenticate_ad( $username, $password ) ) {
        # successful autentication
    }

=head1 DESCRIPTION

Authenticate against Active Directory.

This plugin differs from L<Catalyst::Plugin::Authenticate::LDAP> in way that it
will try to bind directly as the users principial. For a more powerful
alternative see L<Catalyst::Plugin::Authenticate::LDAP>.

=head1 OPTIONS

=over 4

=item host

Can be a host name, IP number or a URI.

    host => ldap.company.com
    host => 10.0.0.1
    host => ldap://ldap.company.com:389
    host => ldaps://ldap.company.com

=item port

Connection port, default to 389. May be overriden by host if host is a URI.

    port => 389

=item timeout

Connection timeout, defaults to 60.

    timeout => 60

=item principal

The suffix in users principal, usally the domain or forrest.

    principal  => 'company.com'

=back

=head1 TODO

Add support for TLS/SSL

=head1 SEE ALSO

L<Net::LDAP>, L<Catalyst::Plugin::Authenticate::LDAP>, L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
