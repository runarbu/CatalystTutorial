package Catalyst::Plugin::Session::Store::FastMmap;

use strict;
use base
  qw/Class::Data::Inheritable Class::Accessor::Fast Catalyst::Plugin::Session::Store/;
use NEXT;
use Cache::FastMmap;
use Path::Class     ();
use File::Spec      ();
use Catalyst::Utils ();

our $VERSION = '0.02';

__PACKAGE__->mk_classdata(qw/_session_fastmmap_storage/);

=head1 NAME

Catalyst::Plugin::Session::Store::FastMmap - FastMmap session storage backend.

=head1 SYNOPSIS

    use Catalyst qw/Session Session::Store::FastMmap Session::State::Foo/;
    
    MyApp->config->{session} = {
        expires => 3600,
        storage => '/tmp/session'
    };

    # ... in an action:
    $c->session->{foo} = 'bar'; # will be saved

=head1 DESCRIPTION

C<Catalyst::Plugin::Session::Store::FastMmap> is a fast session storage plugin
for Catalyst that uses an mmap'ed file to act as a shared memory interprocess
cache. It is based on L<Cache::FastMmap>.

=head2 METHODS

=over 4

=item get_session_data

=item store_session_data

=item delete_session_data

=item delete_expired_sessions

These are implementations of the required methods for a store. See
L<Catalyst::Plugin::Session::Store>.

=item get_and_set_session_data

This is the optional method for atomic write semantics. See
L<Catalyst::Plugin::Session::AtomicWrite>.

=cut

# The reference business is because Cache::FastMmap delegates to Storable with
# no intervention, meaning that non reference data cannot be stored.
# see L<https://rt.cpan.org/NoAuth/Bug.html?id=16762>
# FIXME remember to remove this hack when the new version of Cache::FastMmap is
# out, and to rely on it
sub get_session_data {
    my ( $c, $sid ) = @_;
    ${ $c->_session_fastmmap_storage->get($sid) || return };
}

sub store_session_data {
    my ( $c, $sid, $data ) = @_;
    $c->_session_fastmmap_storage->set( $sid, \$data );
}

sub delete_session_data {
    my ( $c, $sid ) = @_;
    $c->_session_fastmmap_storage->remove($sid);
}

sub delete_expired_sessions { } # unsupported

sub get_and_set_session_data {
    my ( $c, $sid, $sub ) = @_;
    $c->_session_fastmmap_storage->get_and_set( $sid, sub {
        my ( $key, $data ) = @_;
        my $new = $sub->( $key, $$data ); # YUCK about the $$data - see above FIXME
        return \$new;
    });
}

=item setup_session

Sets up the session cache file.

=cut

sub setup_session {
    my $c = shift;

    $c->NEXT::setup_session(@_);

    my $tmpdir = Catalyst::Utils::class2tempdir($c)
      || Catalyst::Exception->throw("Can't determine tempdir for $c");

    my $file = $c->config->{session}{storage} ||=
      File::Spec->catfile(    # Cache::FastMmap doesn't like Path::Class objects
        $tmpdir,
        "session_data",
      );

    Path::Class::dir($tmpdir)->mkpath;

    my $cfg = $c->config->{session};

    $c->_session_fastmmap_storage(
        Cache::FastMmap->new(
            share_file  => $cfg->{storage},
            (
                map { $_ => $cfg->{$_} }
                  grep { exists $cfg->{$_} } qw/init_file cache_size/
            ),
        )
    );
}

=back

=head1 CAVEATS

Very loaded sites with lots of data in the session hash may have old sessions
expired prematurely, due to the LRU caching policy employed by
L<Cache::FastMmap>. To get around this you can increase the C<cache_size>
parameter, or switch session storage backends.

This is particularly inappropriate for use as a backend for e.g.
L<Catalyst::Plugin::Session::PerUser>, for example.

L<Cache::FastMmap> defaults to around 5mb (89 * 64k).

=head1 CONFIGURATION

These parameters are placed in the hash under the C<session> key in the
configuration hash.

=over 4

=item storage

Specifies the file to be used for the sharing of session data. The default
value will use L<File::Spec> to find the default tempdir, and use a file named
C<MyApp_session_data>, where C<MyApp> is replaced with the appname.

Note that the file will be created with mode 0640, which means that it
will only be writeable by processes running with the same uid as the
process that creates the file.  If this may be a problem, for example
if you may try to debug the program as one user and run it as another,
specify a filename like C<< /tmp/session-$> >>, which includes the
UID of the process in the filename.

=item init_file

=item cache_size

See the L<Cache::FastMmap> documentation for the meaning of these keys. If
these keys are not present L<Cache::FastMmap>'s defaults will be used.

=back

=head1 SEE ALSO

L<Catalyst>, L<Catalyst::Plugin::Session>, L<Cache::FastMmap>.

=head1 AUTHORS

This module is derived from L<Catalyst::Plugin::Session::FastMmap> code, and
has been heavily modified since.

Andrew Ford
Andy Grundman
Christian Hansen
Yuval Kogman, C<nothingmuch@woobling.org>
Marcus Ramberg
Sebastian Riedel

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
