package Catalyst::Plugin::Authenticate::Kerberos;

use strict;
use Carp ();
use Authen::Krb5::Simple;

our $VERSION = '0.1';

our $PARAMETERS = qw[
    username
    password
];

*authenticate_krb = \&authenticate_kerberos;    # Makes sri happy ;)

sub authenticate_kerberos {
    my ( $c, $username, $password, $options ) = @_;

    unless ( @_ == 3 || ( @_ == 4 && ref($options) eq 'HASH' ) ) {
        Carp::croak('usage: $c->authenticate_kerberos( $username, $password [, \%options ] )');
    }

    unless ( @_ == 4 ) {
        $options = {};
    }

    my $config = $c->config->{authenticate}->{kerberos};
    my $realm  = $options->{realm} || $config->{realm};

    my @arguments = $realm ? ( realm => $realm ) : ();
    my $kerberos  = Authen::Krb5::Simple->new(@arguments);

    if ( $kerberos->authenticate( $username, $password ) ) {
        return 1;
    }

    {
        my $error = $kerberos->errstr;
        my $realm = $kerberos->realm;
        $c->log->debug( qq/Failed to authenticate user '$username' using realm '$realm'. Reason: '$error'/ );
    }

    return 0;
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Authenticate::Kerberos - Kerberos Authentication

=head1 SYNOPSIS

    use Catalyst qw[Authenticate::Kerberos];

    MyApp->config->{authenticate}->{kerberos} = {
        realm  => 'DOMAIN.COM'
    };

    if ( $c->authenticate_kerberos( $username, $password ) ) {
        # successful autentication
    }

=head1 DESCRIPTION

Kerberos Authentication

=head1 SEE ALSO

L<Authen::Krb5::Simple>, L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
