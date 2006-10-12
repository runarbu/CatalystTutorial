package MiniMojoDBIC::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

sub default : Private {
    my ( $self, $c ) = @_;
    $c->forward('/page/show');
}

sub end : Private {
    my ( $self, $c ) = @_;
    $c->forward('MiniMojoDBIC::View::TT') unless $c->res->output;
}

=head1 NAME

MiniMojoDBIC::Controller::Root - A very nice application

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
