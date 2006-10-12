package TestApp;

use strict;
use base qw[CGI::Catalyst];

sub begin : Private {
    my $self = shift;
    $self->response->content_type('text/plain');
    $self->response->body('OK');
}

sub one : Path('/errors/one') {
    my $self = shift;
    my $a = 0;
    my $b = 0;
    my $t = $a / $b;
}

sub two : Path('/errors/two') {
    my $self = shift;
    $self->forward('/non/existing/path');
}

sub three : Path('/errors/three') {
    my $self = shift;
    die("I'm going to die!\n");
}

1;
