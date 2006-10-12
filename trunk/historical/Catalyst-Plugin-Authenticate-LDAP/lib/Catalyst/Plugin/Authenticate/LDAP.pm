package Catalyst::Plugin::Authenticate::LDAP;

use strict;
use Carp ();
use Net::LDAP;

our $VERSION = '0.1';

our $PARAMETERS = qw[
    username
    password
];

sub authenticate_ldap {
    my ( $c, $username, $password, $options ) = @_;

    unless ( @_ == 3 || ( @_ == 4 && ref($options) eq 'HASH' ) ) {
        Carp::croak('usage: $c->authenticate_ldap( $username, $password [, \%options ] )');
    }

    unless ( @_ == 4 ) {
        $options = {};
    }

    my $config = $c->config->{authenticate}->{ldap};

    # connection
    my $host    = $options->{host}    || $config->{host}    || 'localhost';
    my $port    = $options->{port}    || $config->{port}    || 389;
    my $timeout = $options->{timeout} || $config->{timeout} || 60;
    my $version = $options->{version} || $config->{version} || '3';

    # bind
    my $binddn  = $options->{binddn}  || $config->{binddn}  || undef;
    my $bindpw  = $options->{bindpw}  || $config->{bindpw}  || undef;

    # search
    my $basedn  = $options->{basedn}  || $config->{basedn}  || undef;
    my $scope   = $options->{scope}   || $config->{scope}   || 'sub';
    my $filter  = $options->{filter}  || $config->{filter}  || '(uid=%s)';


    my $connection = Net::LDAP->new( $host,
        Port    => $port,
        Timeout => $timeout,
        Version => $version
    );

    unless ( defined $connection ) {
        $c->log->warn(qq/Failed to connect to '$host'. Reason: '$@'/);
        return 0;
    }

    my ( @credentials, $message, $search, $entry );

    @credentials = $binddn ? ( $binddn, password => $bindpw ) : ();
    $message     = $connection->bind(@credentials);

    if ( $message->is_error ) {

        my $error = $message->error;
        my $bind  = $binddn ? qq/with dn '$binddn'/ : "Anonymously";

        $c->log->warn(qq/Failed to bind $bind. Reason: '$error'/);

        return 0;
    }

    $filter = sprintf( $filter, ($username) x 10 );
    $search = $connection->search(
        base   => $basedn,
        scope  => $scope,
        filter => $filter,
        attrs  => ['1.1']
    );

    if ( $search->is_error ) {

        my $error   = $search->error;
        my $options = qq/basedn '$basedn' with filter '$filter'/;

        $c->log->warn(qq/Failed to search $options. Reason: '$error'/);

        return 0;
    }

    if ( $search->count == 0 ) {
        $c->log->debug(qq/User '$username' was not found with filter '$filter'./);
        return 0;
    }

    if ( $search->count > 1 ) {
        my $count = $search->count;
        $c->log->warn(qq/Found $count matching entries for '$username' with filter '$filter'./);
    }

    $entry   = $search->entry(0);
    $message = $connection->bind( $entry->dn, password => $password );

    if ( $message->is_error ) {

        my $error = $message->error;
        my $dn    = $entry->dn;

        $c->log->debug(qq/Failed to authenticate user '$username' with dn '$dn'. Reason: '$error'/);

        return 0;
    }

    return 1;
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Authenticate::LDAP - Authenticate against a LDAP service

=head1 SYNOPSIS

    use Catalyst qw[Authenticate::LDAP];

    MyApp->config->{authenticate}->{ldap} = {
        host    => 'ldap.company.com',
        basedn  => 'ou=People,dc=company,dc=net'
        filter  => '(uid=%s)',
    };

    if ( $c->authenticate_ldap( $username, $password ) ) {
        # successful autentication
    }

=head1 DESCRIPTION

Authenticate against a LDAP service.

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

=item version

The LDAP version to use, defaults to 3.

    version => 3

=item binddn

The distinguished name to bind to the server with, defaults to bind
anonymously.

    binddn => 'uid=proxy,cn=users,dc=company,dc=com'

=item bindpw

The credentials to bind with.

    bindpw => 'secret'

=item basedn

The distinguished name of the search base.

    basedn => 'cn=users,dc=company,dc=com'

=item filter

LDAP filter to use in search, defaults to C<(uid=%s)>.

    filter => '(uid=%s)'

=item scope

The search scope, can be C<base>, C<one> or C<sub>, defaults to C<sub>.

    filter => 'sub'

=back

=head1 EXAMPLE SETUPS

=head2 Active Directory

    MyApp->config->{authenticate}->{ldap} = {
        host    => 'ad.company.com',
        binddn  => 'proxyuser@company.com',
        bindpw  => 'secret',
        basedn  => 'cn=users,dc=company,dc=com'
        filter  => '(&(objectClass=organizationalPerson)(objectClass=user)(sAMAccountName=%s))'
    };

Active Directory by default does not allow anonymous binds. It's recommended
that a proxy user is created that has sufficient rights to search the desired
tree and attributes.

=head2 Open Directory

    MyApp->config->{authenticate}->{ldap} = {
        host    => 'od.company.com',
        basedn  => 'cn=users,dc=company,dc=com',
        filter  => '(&(objectClass=inetOrgPerson)(objectClass=posixAccount)(uid=%s))'
    };

=head1 TODO

Add support for TLS/SSL

=head1 SEE ALSO

L<Net::LDAP>, L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
