package Cataculous::C::Sortable;

use strict;
use base 'Catalyst::Base';

=head1 NAME

Cataculous::C::Sortable - Catalyst component

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
    $c->stash->{template} = 'sortable.tt';
}

=back


=head1 AUTHOR

Sebastian Riedel

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
