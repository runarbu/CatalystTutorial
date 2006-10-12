package TestApp::Example::PerlIOBody;

use strict;
use base qw[CGI::Catalyst];

use PerlIOBody;

sub prepare {
    my $self = shift;
    $self->response->body( PerlIOBody->new );
    $self->SUPER::prepare(@_);
}

sub begin : Private {
    my $self = shift;
    $self->response->body->print('begin');
}

sub default : Private {
    my $self = shift;
    $self->response->body->print('default');
}

sub end : Private {
    my $self = shift;
    $self->response->body->print('end');
}

1;
