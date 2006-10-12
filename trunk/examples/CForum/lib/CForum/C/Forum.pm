package CForum::C::Forum;

use strict;
use base 'Catalyst::Base';


sub list : Local {
    my ( $self, $c ) = @_;
    $c->stash->{template}='forum/list.tt';
    $c->stash->{page}    = $c->req->param->{page} || 1;
    $c->stash->{forums}  = [CForum::M::CDBI::Forum->retrieve_all];
}

sub view : Local {
    my ( $self, $c, $forum ) = @_;
    $c->stash->{template}='forum/view.tt';
    $c->stash->{forum} = CForum::M::CDBI::Forum->retrieve($forum);
}


=head1 NAME

CForum::C::Forum - The Forum Controller.

=head1 DESCRIPTION

All actions related to the forum.

=head1 AUTHOR

Marcus Ramberg <m.ramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;

