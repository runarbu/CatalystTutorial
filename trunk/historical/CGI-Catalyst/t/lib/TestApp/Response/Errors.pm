package TestApp::Response::Errors;

use strict;
use base qw[CGI::Catalyst];

sub one : Path('/response/errors/one') {
    my $self = shift;
    my $a = 0;
    my $b = 0;
    my $t = $a / $b;
}

sub two : Path('/response/errors/two') {
    my $self = shift;
    $self->forward('/non/existing/path');
}

sub three : Path('/response/errors/three') {
    my $self = shift;
    die("I'm going to die!\n");
}

1;
