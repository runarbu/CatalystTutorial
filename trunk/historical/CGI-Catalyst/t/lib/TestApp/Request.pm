package TestApp::Request;

use strict;
use base qw[CGI::Catalyst];

sub default : Private {
    my $self = shift;
    $self->response->content_type('text/plain');
    $self->response->header( 'X-Action' => ( caller(0) )[3] );
    $self->response->body('OK');
}

1;
