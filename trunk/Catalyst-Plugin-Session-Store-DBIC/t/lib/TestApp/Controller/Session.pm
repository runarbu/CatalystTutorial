package TestApp::Controller::Session;

use strict;
use warnings;
use base qw/Catalyst::Controller/;

sub setup : Local {
    my ($self, $c) = @_;

    my $key   = $c->req->param('key')   || 'key';
    my $value = $c->req->param('value') || 1;

    $c->session->{$key} = $value;
    $c->res->body('ok');
}

sub output : Local {
    my ($self, $c) = @_;

    my $key = $c->req->param('key') || 'key';

    $c->res->body($c->session->{$key});
}

1;
