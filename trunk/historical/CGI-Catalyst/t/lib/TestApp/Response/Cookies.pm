package TestApp::Response::Cookies;

use strict;
use base qw[CGI::Catalyst];

sub one : Path('/response/cookies/one') {
    my $self = shift;
    $self->response->cookies->{CookieA} = { value => 'ValueA', path => '/' };
    $self->response->cookies->{CookieB} = { value => 'ValueB', path => '/' };
}

sub two : Path('/response/cookies/two') {
    my $self = shift;
    $self->response->cookies->{CookieA} = { value => 'ValueA', path => '/' };
    $self->response->cookies->{CookieB} = { value => 'ValueB', path => '/' };
    $self->response->redirect('http://www.google.com/');
}

1;
