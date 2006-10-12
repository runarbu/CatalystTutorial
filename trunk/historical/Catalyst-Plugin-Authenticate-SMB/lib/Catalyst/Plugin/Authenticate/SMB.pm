package Catalyst::Plugin::Authenticate::SMB;

use strict;
use Carp ();
use Authen::Smb;

our $VERSION = '0.1';

our $PARAMETERS = qw[
    username
    password
];

sub authenticate_smb {
    my ( $c, $username, $password, $options ) = @_;

    unless ( @_ == 3 || ( @_ == 4 && ref($options) eq 'HASH' ) ) {
        Carp::croak('usage: $c->authenticate_smb( $username, $password [, \%options ] )');
    }

    unless ( @_ == 4 ) {
        $options = {};
    }

    my $config = $c->config->{authenticate}->{smb};

    my $domain = $options->{domain} || $config->{domain};
    my $pdc    = $options->{pdc}    || $config->{pdc};
    my $bdc    = $options->{bdc}    || $config->{bdc};


    my $status = Authen::Smb::authen( $username, $password, $pdc, $bdc, $domain );

    if ( $status == 0 ) { # NTV_NO_ERROR
        $c->log->debug( qq/Successfully authenticated user '$username'./);
        return 1;
    }

    if ( $status == 1 ) { # NTV_SERVER_ERROR
        $c->log->warn( qq/Received a Server Error/ );
    }

    if ( $status == 2 ) { # NTV_PROTOCOL_ERROR
        $c->log->warn( qq/Received a Protocol Error/ );
    }

    if ( $status == 3 ) { # NTV_LOGON_ERROR
        $c->log->debug( qq/User '$username' credentials is invalid'./);
    }

    return 0;
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Authenticate::SMB - SMB Authentication

=head1 SYNOPSIS

    use Catalyst qw[Authenticate::SMB];

    MyApp->config->{authenticate}->{smb} = {
        domain => 'COMPANY',
        pdc    => 'PDC',
        bdc    => 'BDC'
    };

    if ( $c->authenticate_smb( $username, $password ) ) {
        # successful autentication
    }

=head1 DESCRIPTION

SMB Authentication

=head1 SEE ALSO

L<Authen::Smb>, L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
