package TestApp::Response::Status;

use strict;
use base qw[CGI::Catalyst];

sub s200 : Path('/response/status/s200') {
    my $self = shift;
    $self->response->status(200);
    $self->response->body("200 OK\n");
}

sub s400 : Path('/response/status/s400') {
    my $self = shift;
    $self->response->status(400);
    $self->response->body("400 Bad Request\n");
}

sub s403 : Path('/response/status/s403') {
    my $self = shift;
    $self->response->status(403);
    $self->response->body("403 Forbidden\n");
}

sub s404 : Path('/response/status/s404') {
    my $self = shift;
    $self->response->status(404);
    $self->response->body("404 Not Found\n");
}

sub s500 : Path('/response/status/s500') {
    my $self = shift;
    $self->response->status(500);
    $self->response->body("500 Internal Server Error\n");
}

1;
