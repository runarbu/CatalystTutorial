package Cataculous;

use strict;
use Catalyst qw/-Debug Prototype/;

our $VERSION = '0.01';

Cataculous->config( name => 'Cataculous AJAX examples!' );

Cataculous->setup;

=head1 NAME

Cataculous - Catalyst based application

=head1 SYNOPSIS

    script/cataculous_server.pl

=head1 DESCRIPTION

Catalyst based application.

=head1 METHODS

=over 4

=item default

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'index.tt';
}

=item end

=cut

sub end : Private {
    my ( $self, $c ) = @_;
    $c->forward('Cataculous::V::TT') unless $c->res->body;
}

=back

=head1 AUTHOR

Sebastian Riedel

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
