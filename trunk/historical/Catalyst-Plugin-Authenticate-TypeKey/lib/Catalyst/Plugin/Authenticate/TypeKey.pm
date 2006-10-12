package Catalyst::Plugin::Authenticate::TypeKey;

use strict;
use Authen::TypeKey;
use Carp ();
use File::Spec;

our $VERSION = '0.1';

our $PARAMETERS = qw[
    email
    name
    nick
    ts
    sig
];

sub authenticate_typekey {
    my ( $c, $email, $name, $nick, $ts, $sig, $options ) = @_;

    unless ( @_ == 6 || ( @_ == 7 && ref($options) eq 'HASH' ) ) {
        Carp::croak('usage: $c->authenticate_typekey( $email, $name, $nick, $ts, $sig [, \%options ] )');
    }

    unless ( @_ == 7 ) {
        $options = {};
    }

    my $config = $c->config->{authenticate}->{typekey};

    my $token   = $options->{token}   || $config->{token}   || undef;
    my $expires = $options->{expires} || $config->{expires} || 0;
    my $version = $options->{version} || $config->{version} || 1.1;
    my $cache   = $options->{cache}   || $config->{cache}   || File::Spec->catfile( File::Spec->tmpdir, 'regkeys.txt' );
    my $keys    = $options->{keys}    || $config->{keys}    || 'http://www.typekey.com/extras/regkeys.txt';

    my $typekey = Authen::TypeKey->new;
    $typekey->expires($expires);
    $typekey->key_cache($cache);
    $typekey->key_url($keys);
    $typekey->token($token);
    $typekey->version($version);

    my $parameters = {
        email => $email,
        name  => $name,
        nick  => $nick,
        ts    => $ts,
        sig   => $sig
    };

    unless ( $typekey->verify($parameters) ) {
        my $error = $typekey->errstr;
        $c->log->debug(qq/Failed to authenticate user '$name'. Reason: '$error'/);
        return 0;
    }

    $c->log->debug( qq/Successfully authenticated user '$name'./);
    return 1;
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Authenticate::TypeKey - TypeKey Authentication

=head1 SYNOPSIS

    use Catalyst qw[Authenticate::TypeKey];

    MyApp->config->{authenticate}->{typekey} = {
        token => 'xxxxxxxxxxxxxxxxxxxx'
    };

    if ( $c->authenticate_typekey( $email, $name, $nick, $ts, $sig ) ) {
        # successful autentication
    }

=head1 DESCRIPTION

TypeKey Authentication.

=head1 SEE ALSO

L<Authen::TypeKey>, L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
