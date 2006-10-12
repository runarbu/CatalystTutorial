package Catalyst::Plugin::Authenticate::OpenID;

use strict;
use Cache::FileCache;
use Carp ();
use File::Spec;
use Net::OpenID::Consumer;

our $VERSION = '0.1';

our $PARAMETERS = qw[
    openid.mode
    openid.assert_identity
    openid.return_to
    openid.timestamp
    openid.sig
];

sub authenticate_openid {
    my ( $c, $mode, $identity, $return, $timestamp, $sig, $options ) = @_;

    unless ( @_ == 6 || ( @_ == 7 && ref($options) eq 'HASH' ) ) {
        Carp::croak('usage: $c->authenticate_openid( $mode, $identity, $return, $timestamp, $sig [, \%options ] )');
    }

    unless ( @_ == 7 ) {
        $options = {};
    }

    my $config = $c->config->{authenticate}->{openid};

    my $agent  = $options->{agent}  || $config->{agent}  || undef;
    my $cache  = $options->{cache}  || $config->{cache}  || Cache::FileCache->new( { namespace => 'OpenID' } );
    my $tmpdir = $options->{tmpdir} || $config->{tmpdir} || File::Spec->tmpdir;

    my $openid = Net::OpenID::Consumer->new(
        args   => {
            'openid.mode'            => $mode,
            'openid.assert_identity' => $identity,
            'openid.return_to'       => $return,
            'openid.timestamp'       => $timestamp,
            'openid.sig'             => $sig
        },
        cache  => $cache,
        tmpdir => $tmpdir,
        ua     => $agent
    );

    unless ( $openid->verified_identity ) {
        my $error = $openid->err;
        $c->log->debug(qq/Failed to authenticate user '$identity'. Reason: '$error'/);
        return 0;
    }

    $c->log->debug( qq/Successfully authenticated user '$identity'./);
    return 1;
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Authenticate::OpenID - OpenID Authentication

=head1 SYNOPSIS

    use Catalyst qw[Authenticate::OpenID];

    if ( $c->authenticate_openid( $mode, $identity, $return, $timestamp, $sig ) ) {
        # successful autentication
    }

=head1 DESCRIPTION

OpenID Authentication.

=head1 SEE ALSO

L<Net::OpenID::Consumer>, L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
