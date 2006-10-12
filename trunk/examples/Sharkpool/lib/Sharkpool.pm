package Sharkpool;

use strict;
use Catalyst qw/-Debug Static/;
use YAML qw/LoadFile/;
use Path::Class qw/file/;

our $VERSION = '0.01';

Sharkpool->config(
    LoadFile( file( Sharkpool->config->{home}, 'sharkpool.yml' ) ) );

Sharkpool->setup;

sub default : Private {
    my ( $self, $c ) = @_;
    $c->res->output('Congratulations, Sharkpool is on Catalyst!');
}

sub end : Private {
    my ( $self, $c ) = @_;

    return 1 if $c->response->status =~ /^3\d\d$/;
    return 1 if $c->response->body;

    unless ( $c->response->content_type ) {
        $c->response->content_type('text/html; charset=utf-8');
    }

    $c->forward('Sharkpool::V::TT');
}

=head1 NAME

Sharkpool - A very nice application

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice application.

=head1 AUTHOR

Sebastian Riedel

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;

