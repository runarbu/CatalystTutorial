package TestApp::Response;

use strict;
use base qw[ TestApp::Response::Cookies
             TestApp::Response::Errors
             TestApp::Response::Headers
             TestApp::Response::Redirect
             TestApp::Response::Status   ];

sub begin : Private {
    my $self = shift;
    $self->response->content_type('text/plain');
    $self->response->body('OK');
}

sub basic : Path('/response') {
    my $self = shift;
    $self->response->status(200);
    $self->response->content_type('text/plain; charset="UTF-8"');
    $self->response->header( 'X-CGI-Catalyst-Version' => $CGI::Catalyst::VERSION );
    $self->response->cookies->{test} = { value => 'test' };
    $self->response->body('OK');
}

1;
