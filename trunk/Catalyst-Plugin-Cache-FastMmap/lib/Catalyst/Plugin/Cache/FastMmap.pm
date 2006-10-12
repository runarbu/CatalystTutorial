package Catalyst::Plugin::Cache::FastMmap;

use strict;
use base 'Class::Data::Inheritable';

use Cache::FastMmap;

our $VERSION= '0.6';

__PACKAGE__->mk_classdata('cache');

sub setup {
    my $self = shift;

    my %params = ();

    if ( $self->config->{cache} ) {
        %params = %{ $self->config->{cache} };
    }

    if ( $params{storage} ) {
        $params{share_file} = delete $params{storage};
    }

    if ( $params{expires} ) {
        $params{expire_time} = delete $params{expires};
    }

    $self->cache( Cache::FastMmap->new(%params) );

    return $self->NEXT::setup(@_);
}

1;


__END__

=head1 NAME

Catalyst::Plugin::Cache::FastMmap - Mmap cache

=head1 SYNOPSIS

    use Catalyst qw[Cache::FastMmap];

    MyApp->config->{cache}->{storage} = '/tmp/cache';
    MyApp->config->{cache}->{expires} = 3600;

    my $data;

    unless ( $data = $c->cache->get('data') ) {
        $data = MyApp::Model::Data->retrieve('data');
        $c->cache->set( 'data', $data );
    }

    $c->response->body($data);


=head1 DESCRIPTION

This package is part of the Catalyst Cache family. It allows
integration of L<Cache::FastMmap> and L<Catalyst>

This module extends the Catalyst application class with a C<mmap> cache.

=head1 METHODS

=over 4

=item cache

Returns an instance of C<Cache::FastMmap>

=back

=head1 SEE ALSO

L<Cache::FastMmap>, L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>
Sebastian Riedel C<sri@oook.de>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
