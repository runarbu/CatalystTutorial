package Cataculous::C::AutoComplete;

use strict;
use base 'Catalyst::Base';

=head1 NAME

Cataculous::C::AutoComplete - Catalyst component

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
    $c->stash->{template} = 'autocomplete.tt';
}

=item suggest

=cut

sub suggest : Local {
    my ( $self, $c ) = @_;

    my $complete_me = $c->req->params->{complete_me};
    my @suggestions;
    push @suggestions, "$complete_me$_" for 1 .. 5;

    $c->res->body( $c->prototype->auto_complete_result( \@suggestions ) );
}

=back


=head1 AUTHOR

Sebastian Riedel

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
