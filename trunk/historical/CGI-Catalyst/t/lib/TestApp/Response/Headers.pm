package TestApp::Response::Headers;

use strict;
use base qw[CGI::Catalyst];

sub one : Path('/response/headers/one') {
    my $self = shift;
    $self->response->header( 'X-Header-A'        => 'A'         );
    $self->response->header( 'X-Header-B'        => 'B'         );
    $self->response->header( 'X-Header-Numbers'  => [ 1 .. 10 ] );
}

1;
