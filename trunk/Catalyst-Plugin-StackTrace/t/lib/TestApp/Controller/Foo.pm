package TestApp::Controller::Foo;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub ok : Local {
    my ( $self, $c ) = @_;
    
    $c->res->output( 'ok' );
}

sub not_ok : Local {
    my ( $self, $c ) = @_;
    
    $c->forward( 'crash' );
}

sub crash : Local {
    my ( $self, $c ) = @_;
    
    three();
}

1;
