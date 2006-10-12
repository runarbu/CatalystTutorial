package CatalystX::Blog::Controller::Static;

use strict;
use base 'Catalyst::Base';

sub end : Private {
     my ( $self, $c ) = @_;
    $c->response->header( 'Cache-Control' => 'max-age=86400' );
}

sub default : Private {
    my($self, $c) = @_;
    $c->serve_static;
}

sub css : Regex('(?i)\.(?:css)') {
    my($self, $c) = @_;
    $c->serve_static("text/css");
}

sub ico : Regex('(?i)\.(?:ico)') {
    my($self, $c) = @_;
    $c->serve_static("image/vnd.microsoft.icon");
}

sub js : Regex('(?i)\.(?:js)') {
    my($self, $c) = @_;
    $c->serve_static("application/x-javascript");
}

1;
