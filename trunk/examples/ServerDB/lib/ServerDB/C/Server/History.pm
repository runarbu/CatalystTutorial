package ServerDB::C::Server::History;

use strict;
use base 'Catalyst::Base';

sub default : Private {
    my ( $self, $c ) = @_;
    $c->forward('/server/list');
}

sub auto : Private {
	my ($self, $c) = @_;
	$c->stash->{servernav} = "history";
	return 1;
}

sub history : Path('/server/history') {
	my ($self, $c, @name) = @_;
	
	$c->stash->{template} = "server/history.xhtml";
}

1;
