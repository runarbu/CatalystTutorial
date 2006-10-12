package FcgiTest::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

__PACKAGE__->config->{namespace} = '';

sub index : Private {
    my ( $self, $c) = @_;
    $c->res->body('hit index');
}

sub default : Private {
    my ( $self, $c ) = @_;
    $c->res->body('hit default');
}

sub local_action : Local {
    my ( $self, $c ) = @_;
    $c->res->body('hit localaction');
}

1;
