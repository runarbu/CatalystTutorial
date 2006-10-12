#!/usr/bin/perl

package Catalyst::Plugin::Session::AtomicWrite;
use base qw/Class::Accessor/;

use strict;
use warnings;

use Storable ();
use Data::Compare ();
use Hash::Merge ();
use Config::PackageGlobal::OO;

__PACKAGE__->mk_accessors(qw/_original_session_data/);

sub setup {
    my $c = shift;

    warn "Session store must support the atomic "
      . "'get_and_set_session_data' method"
      unless $c->can('set_and_get_session_data');

    $c->NEXT::setup(@_);
}

sub store_session_data {
    my ( $c, $key, $new ) = @_;

    my $old = $c->get_original_session_data($key);

    $c->get_and_set_session_data(
        $key,
        sub {
            my ( $key, $on_disk ) = @_;
            my $merged = $c->merge_session_data( $key, $new, $on_disk, $old );
            $merged;
        }
    );
}

sub merge_session_data {
    my $c = shift;
    my ( $key, $new, $on_disk, $old ) = @_;

    if ( !$c->compare_session_data( @_ ) ) {
        return $c->resolve_session_data( @_ );
    } else {
        return $new;
    }
}

sub compare_session_data {
    my ( $c, $key, $new, $on_disk, $old ) = @_;
    Data::Compare::Compare( $on_disk, $old );
}

sub resolve_session_data {
    my ( $c, $key, $new, $on_disk, $old ) = @_;

    return $new if !$old or !$new;

    my $o = Config::PackageGlobal::OO->new( "Hash::Merge", "merge" );

    $o->behavior( "LEFT_PRECEDENT" );
    $o->clone_behavior( 0 );

    return $o->merge( $new, $on_disk );
}

sub save_original_session_data {
    my ( $c, $key, $data ) = @_;

    my $hash = $c->_original_session_data
      || $c->_original_session_data( {} );

    $hash->{$key} = Storable::dclone($data);
}

sub get_original_session_data {
    my ( $c, $key ) = @_;
    ( $c->_original_session_data || {} )->{$key};
}

sub get_session_data {
    my ( $c, $key ) = @_;

    my $data = $c->NEXT::get_session_data($key);

    $c->save_original_session_data( $key, $data )
      unless ( $key =~ /^expires:/ );

    return $data;
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Catalyst::Plugin::Session::AtomicWrite - Overkill safety in Catalyst sessions ;-)

=head1 SYNOPSIS

    use Catalyst::Plugin::Session::AtomicWrite;

=head1 DESCRIPTION

=cut


