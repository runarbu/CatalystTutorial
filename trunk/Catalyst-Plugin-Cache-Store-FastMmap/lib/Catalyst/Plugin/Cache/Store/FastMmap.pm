#!/usr/bin/perl

package Catalyst::Plugin::Cache::Store::FastMmap;

use strict;
use warnings;

use Path::Class     ();
use File::Spec      ();
use Catalyst::Utils ();
use Catalyst::Plugin::Cache::Backend::FastMmap;

sub setup_fastmmap_cache_backend {
    my ( $app, $name, $config ) = @_;

    $config->{share_file} ||= File::Spec->catfile( Catalyst::Utils::class2tempdir($app), "cache_$name" );

    # make sure it exists
    Path::Class::file( $config->{share_file} )->parent->mkpath; 

    $app->register_cache_backend(
        $name => Catalyst::Plugin::Cache::Backend::FastMmap->new( %$config )
    );
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Catalyst::Plugin::Cache::Store::FastMmap - FastMmap cache store class.

=head1 SYNOPSIS

    use Catalyst qw/
        Cache
        Cache::Store::FastMmap
    /;

    __PACKAGE__->config( cache => {
        backend => {
            share_file => "/path/to/file",
            cache_size => "16m",
            # any other Cache::Cache config param
        },
    });

=head1 DESCRIPTION

=head1 CONFIGURATION

See L<Catalyst::Plugin::Cache/CONFIGURATION> for a general overview of cache
plugin configuration.

This plugin just takes a hash reference in the backend field and passes it on
to L<Cache::FastMmap>.

=cut


