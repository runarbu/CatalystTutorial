package CForum;

use strict;
use Catalyst qw/-Debug/;

our $VERSION = '0.01';

CForum->config(
    name => 'CForum',
    root => '/home/marcus/src/CForum/root',
);

CForum->setup;

sub default : Private {
    my ( $self, $c, $action ) = @_;
    if ($action) {
        #$c->forward('/not_found');
        $c->forward('cool-test');
    } else {
        $c->forward('/forum/list');
    }
}


sub not_found : Private {
    my ( $self, $c ) = @_;
    $c->res->status(404);
    $c->stash->{template} = '404.tt';
}

sub end : Private {
    my ( $self, $c ) = @_;
    $c->forward('CForum::V::TT') unless $c->res->output;
}

sub cool-test : Private {
    my ( $self, $c ) = @_;
    $c->res->output('blah');
}

=head1 NAME

CForum - Catalyst Forum


=head1 DESCRIPTION

A Catalyst powered discussion forum

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;
