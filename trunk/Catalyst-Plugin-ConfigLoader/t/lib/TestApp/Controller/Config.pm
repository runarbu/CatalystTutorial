package TestApp::Controller::Config;

use strict;
use warnings;

use base qw( Catalyst::Controller );

sub index : Private {
	my( $self, $c ) = @_;
	$c->res->output( $self->{ foo } );
}

1;