package TestApp::View::Dump::Response;

use strict;
use base qw[TestApp::View::Dump];

sub process {
    my ( $self, $c ) = @_;
    return $self->SUPER::process( $c, $c->response );
}

1;
