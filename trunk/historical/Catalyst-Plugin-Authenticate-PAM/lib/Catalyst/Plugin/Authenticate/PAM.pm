package Catalyst::Plugin::Authenticate::PAM;

use strict;
use Carp ();
use Authen::PAM;

our $VERSION = '0.1';

our $PARAMETERS = qw[
    username
    password
];

sub authenticate_pam {
    my ( $c, $username, $password, $options ) = @_;

    unless ( @_ == 3 || ( @_ == 4 && ref($options) eq 'HASH' ) ) {
        Carp::croak('usage: $c->authenticate_pam( $username, $password [, \%options ] )');
    }

    unless ( @_ == 4 ) {
        $options = {};
    }

    my $config  = $c->config->{authenticate}->{pam};
    my $service = $options->{service} || $config->{service} || 'login';

    my $handler = sub {
        my @response = ();

        while (@_) {
            my $code    = shift;
            my $message = shift;
            my $answer  = undef;

            if ( $code == PAM_PROMPT_ECHO_ON ) {
                $answer = $username;
            }

            if ( $code == PAM_PROMPT_ECHO_OFF ) {
                $answer = $password;
            }

            push( @response, PAM_SUCCESS, $answer );
        }

        return ( @response, PAM_SUCCESS );
    };


    my $pam = Authen::PAM->new( $service, $username, $handler );

    unless ( ref $pam ) {

        my $error = undef;

        if ( $pam == PAM_SERVICE_ERR ) {
            $error = 'Error in service module.';
        }

        if ( $pam == PAM_SYSTEM_ERR ) {
            $error = 'System error.';
        }

        if ( $pam == PAM_BUF_ERR ) {
            $error = 'Memory buffer error.';
        }

        $error ||= "Unknown error has occurred with code '$pam'.";

        $c->log->warn(qq/Failed to start pam service '$service'. Reason: '$error'/);

        return 0;
    }

    my $result = $pam->pam_authenticate;

    unless ( $result == PAM_SUCCESS ) {

        my $error = undef;

        if ( $result == PAM_AUTH_ERR ) {
            $error = 'Authentication failure.';
        }

        if ( $result == PAM_CRED_INSUFFICIENT ) {
            $error = 'Cannot access authentication data due to insufficient credentials.';
        }

        if ( $result == PAM_AUTHINFO_UNAVAIL ) {
            $error = 'Underlying authentication service cannot retrieve authentication information.';
        }

        if ( $result == PAM_USER_UNKNOWN ) {
            $error = 'User not known to the underlying authentication module.';
        }

        if ( $result == PAM_MAXTRIES ) {
            $error = 'An authentication service has maintained a retry count which has been reached.';
        }

        $error ||= "Unknown error has occurred with code '$result'.";

        $c->log->debug(qq/Failed to authenticate user '$username' by service '$service'. Reason: '$error'/);

        return 0;
    }

    $result = $pam->pam_acct_mgmt;

    unless ( $result == PAM_SUCCESS ) {

        my $error = undef;

        if ( $result == PAM_PERM_DENIED ) {
            $error = 'Permission denied.';
        }

        if ( $result == PAM_AUTHTOK_ERR ) {
            $error = 'A failure occurred while updating the authentication token.';
        }

        if ( $result == PAM_USER_UNKNOWN ) {
            $error = 'The user is not known to the authentication module.';
        }

        if ( $result == PAM_TRY_AGAIN ) {
            $error = 'Preliminary checks for changing the password have failed. Try again later.';
        }

        $error ||= "Unknown error has occurred with code '$result'.";

        $c->log->debug(qq/Failed to verify user '$username' by service '$service'. Reason: '$error'/);

        return 0;
    }

    $c->log->debug(qq/Successfully authenticated user '$username' by service '$service'./);

    return 1;
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Authenticate::PAM - PAM Authentication

=head1 SYNOPSIS

    use Catalyst qw[Authenticate::PAM];

    MyApp->config->{authenticate}->{pam} = {
        service  => login'
    };

    if ( $c->authenticate_pam( $username, $password ) ) {
        # successful autentication
    }

=head1 DESCRIPTION

PAM Authentication

=head1 SEE ALSO

L<Authen::PAM>, L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
