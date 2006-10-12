package Catalyst::Plugin::Authenticate::CDBI;

use strict;
use Carp ();
use UNIVERSAL::require;

our $VERSION = '0.1';

our $PARAMETERS = qw[
    username
    password
];

sub authenticate_cdbi {
    my ( $c, $username, $password, $options ) = @_;

    unless ( @_ == 3 || ( @_ == 4 && ref($options) eq 'HASH' ) ) {
        Carp::croak('usage: $c->authenticate_cdbi( $username, $password [, \%options ] )');
    }

    unless ( @_ == 4 ) {
        $options = {};
    }

    my $config = $c->config->{authenticate}->{cdbi};

    my $class     = $options->{class}    || $config->{class}    || undef;
    my $uaccessor = $options->{username} || $config->{username} || 'username';
    my $paccessor = $options->{password} || $config->{password} || 'password';

    unless ( defined $class ) {
        $c->log->warn( qq/CDBI user class is not defined/ );
        return 0;
    }

    unless ( $class->require ) {
        my $error = $UNIVERSAL::require::ERROR;
        $c->log->warn( qq/Failed to require class '$class'. Reason: '$error'/ );
        return 0;
    }

    unless ( $class->can($uaccessor) ) {
        $c->log->warn( qq/Class '$class' does not have a username accessor named '$uaccessor'/ );
        return 0;
    }

    unless ( $class->can($paccessor) ) {
        $c->log->warn( qq/Class '$class' does not have a password accessor named '$paccessor'/ );
        return 0;
    }

    my $user = $class->retrieve( $uaccessor => $username );

    unless ( defined $user ) {
        $c->log->debug(qq/User '$username' was not found./);
        return 0;
    }

    unless ( $user->get($paccessor) eq $password ) {
        $c->log->debug( qq/User '$username' credentials is invalid'./);
        return 0;
    }

    $c->log->debug( qq/Successfully authenticated user '$username'./);
    return 1;
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Authenticate::CDBI - Authenticate against a CDBI class

=head1 SYNOPSIS

    use Catalyst qw[Authenticate::CDBI];

    MyApp->config->{authenticate}->{cdbi} = {
        class    => 'MyApp::Model::User',
        username => 'username',
        password => 'password'
    };

    if ( $c->authenticate_cdbi( $username, $password ) ) {
        # successful authentication
    }

=head1 DESCRIPTION

Authenticate against a CDBI class.

=head1 SEE ALSO

L<Class::DBI>, L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
