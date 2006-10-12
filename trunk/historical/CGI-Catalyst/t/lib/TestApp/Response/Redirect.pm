package TestApp::Response::Redirect;

use strict;
use base qw[CGI::Catalyst];

sub one : Path('/response/redirect/one') {
    my $self = shift;
    $self->response->redirect('/test/writing/is/boring');
}

sub two : Path('/response/redirect/two') {
    my $self = shift;
    $self->response->redirect('http://www.google.com/');
}

sub three : Path('/response/redirect/three') {
    my $self = shift;
    $self->response->redirect('http://www.google.com/');
    $self->response->status(301); # Moved Permanently
}

sub four : Path('/response/redirect/four') {
    my $self = shift;
    $self->response->redirect('http://www.google.com/');
    $self->response->status(307); # Temporary Redirect
}

1;
