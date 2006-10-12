package Cataculous::C::DragDrop;

use strict;
use base 'Catalyst::Base';

=head1 NAME

Cataculous::C::DragDrop - Catalyst component

=head1 SYNOPSIS

See L<Cataculous>

=head1 DESCRIPTION

Catalyst component.

=head1 METHODS

=over 4

=item default

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'dragdrop.tt';
}

=item dropped

=cut

sub dropped : Local {
    my ( $self, $c ) = @_;
    my $dropped = $c->req->params->{id};
    $c->log->debug("Dropped $dropped!");
}

=back


=head1 AUTHOR

Sebastian Riedel

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
