package Catalyst::Plugin::Authenticate::Passwd;

use strict;

use Carp ();
use Crypt::PasswdMD5 ();
use Digest::SHA1;
use Digest::MD5;
use IO::File;

our $VERSION = '0.1';

our $PARAMETERS = qw[
    username
    password
];

sub authenticate_passwd {
    my ( $c, $username, $password, $options ) = @_;

    unless ( @_ == 3 || ( @_ == 4 && ref($options) eq 'HASH' ) ) {
        Carp::croak('usage: $c->authenticate_passwd( $username, $password [, \%options ] )');
    }

    unless ( @_ == 4 ) {
        $options = {};
    }

    my $config     = $c->config->{authenticate}->{passwd};
    my $passwd     = $options->{passwd}     || $config->{passwd}     || '/etc/passwd';
    my $encryption = $options->{encryption} || $config->{encryption} || 'md5';
    my $algorithm  = $options->{algorithm}  || $config->{algorithm}  || 'guess';

    unless ( $encryption =~ /^(crypt|md5|plaintext|sha)$/ ) {
        $c->log->warn(qq/Unsupported encryption '$encryption'./);
        return 0;
    }

    unless ( $algorithm =~ /^(apache|unix|guess)$/ ) {
        $c->log->warn(qq/Unsupported algorithm '$algorithm'./);
        return 0;
    }

    unless ( -e $passwd ) {
        $c->log->warn(qq/passwd file '$passwd' does not exist./);
        return 0;
    }

    unless ( -f $passwd ) {
        $c->log->warn(qq/passwd file '$passwd' is not a file./);
        return 0;
    }

    unless ( -r $passwd ) {
        $c->log->warn(qq/passwd file '$passwd' is not readable by effective uid '$>'./);
        return 0;
    }

    my $fh;

    unless ( $fh = IO::File->new( $passwd, O_RDONLY | O_SHLOCK ) ) {
        $c->log->warn(qq/Failed to open passwd '$passwd'. Reason: '$!'/);
        return 0;
    }

    my $encrypted;

    while ( $_ = $fh->getline ) {

        next if /^#/;
        next if /^\s+/;

        chop;

        my (@credentials) = split( /:/, $_, 3 );

        if ( $credentials[0] eq $username ) {
            $encrypted = $credentials[1];
            $c->log->debug(qq/Found user '$username' in passwd '$passwd'./);
            last;
        }
    }

    unless ( $fh->close ) {
        $c->log->warn(qq/Failed to close passwd '$passwd'. Reason: '$!'/);
        return 0;
    }

    unless ( defined $encrypted ) {
        $c->log->debug(qq/User '$username' was not found in '$passwd'./);
        return 0;
    }

    if ( $encryption eq 'crypt' ) {
        $password = crypt( $password, $encrypted );
    }

    if ( $encryption eq 'md5' && $algorithm eq 'guess' ) {

        if ( $encrypted =~ /^\$apr1\$/ ) {
            $algorithm = 'apache';
        }

        if ( $encrypted =~ /^\$1\$/) {
            $algorithm = 'unix';
        }

        if ( $algorithm eq 'guess' ) {
            $c->log->warn(qq/Failed to guess md5 algorithm from password '$encrypted'./);
            return 0;
        }
    }

    if ( $encryption eq 'md5' && $algorithm eq 'apache' ) {
        $password = Crypt::PasswdMD5::apache_md5_crypt( $password, $encrypted );
    }

    if ( $encryption eq 'md5' && $algorithm eq 'unix' ) {
        $password = Crypt::PasswdMD5::unix_md5_crypt( $password, $encrypted );
    }

    if ( $encryption eq 'plaintext' ) {
        # no need todo anything :)
    }

    if ( $encryption eq 'sha' ) {
        $password = sprintf( '{SHA}%s=', Digest::SHA1::sha1_base64($password) );
    }

    unless ( $password eq $encrypted ) {
        $c->log->debug( qq/User '$username' credentials is invalid'./);
        return 0;
    }

    $c->log->debug( qq/Successfully authenticated user '$username'./);
    return 1;
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Authenticate::Passwd - Passwd Authentication

=head1 SYNOPSIS

    use Catalyst qw[Authenticate::Passwd];

    MyApp->config->{authenticate}->{passwd} = {
        passwd     => '/etc/passwd',
        encryption => 'md5',           # crypt, md5, sha or plaintext
    };

    if ( $c->authenticate_passwd( $username, $password ) ) {
        # successful autentication
    }

=head1 DESCRIPTION

Authenticate against a C<passwd> file.

=head1 SEE ALSO

L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
