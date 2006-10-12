package MiniMojo;

use strict;
use Catalyst qw/-Debug Prototype Textile/;

our $VERSION = '0.01';

MiniMojo->config( name => 'MiniMojo' );

MiniMojo->setup;

sub default : Private {
    my ( $self, $c ) = @_;
    $c->forward('/page/show');
}

sub end : Private {
    my ( $self, $c ) = @_;
    $c->forward('MiniMojo::V::TT') unless $c->res->output;
}

=head1 NAME

MiniMojo - A very nice application

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice application.

=head1 AUTHOR

Clever guy

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
