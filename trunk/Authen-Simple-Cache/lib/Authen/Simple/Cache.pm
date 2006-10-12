package Authen::Simple::Cache;

use strict;
use warnings;
use base 'Authen::Simple::Decorator';

use Params::Validate qw[];

our $VERSION = 0.1;

__PACKAGE__->options({
    cache => {
        type     => Params::Validate::OBJECT,
        can      => [ qw[get set] ],
        optional => 0
    }
});

sub authenticate {
    my ( $self, $username, $password ) = ( shift(@_), @_ );

    my $status;

    if ( $status = $self->cache->get("$username:$password") ) {

        $self->log->debug( qq/Successfully authenticated user '$username' from cache./ )
          if $self->log;

        return $status;
    }

    $status = $self->decorated->authenticate(@_);

    if ( $status ) {

        $self->log->debug( qq/Caching successful authentication for user '$username'./ )
          if $self->log;

        $self->cache->set( "$username:$password" => $status );
    }

    return $status;
}

1;

__END__

=head1 NAME

Authen::Simple::Cache - Simple Cache class

=head1 SYNOPSIS

    my $simple = Authen::Simple::Cache->new(
        decorated => Authen::Simple::Passwd->new( path => '/etc/passwd' ),
        cache     => Cache::FileCache->new
    );

    $simple->authenticate( $username, $password );


=head1 DESCRIPTION

Provides caching of successful authentications.

=head1 METHODS

=over 4

=item * new

This method takes a hash of parameters. The following options are
valid:

=over 8

=item * decorated

An object that C<can>: C<authenticate>. Required.

    decorated => Authen::Simple::Passwd( path => '/etc/passwd' )
    decorated => Authen::Simple->new( .. )

=item * cache

An object that C<can>: C<get> and C<set>. Required.

    cache => Cache::FileCache->new
    cache => Cache::FastMmap->new

=item * log

An object that C<can>: C<debug>, C<info>, C<error> and C<warn>.

    log => Log::Log4perl->get_logger('Authen::Simple::DBI')

=back

=item * authenticate( $username, $password )

Returns true on success and false on failure.

=back

=head1 SEE ALSO

L<Authen::Simple>

L<Authen::Simple::Callback>

=head1 AUTHOR

Christian Hansen C<ch@ngmedia.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify 
it under the same terms as Perl itself.

=cut

