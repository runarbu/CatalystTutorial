package Catalyst::Plugin::Test::Errors;

use strict;

sub error {
    my $c = shift;

    unless ( $_[0] ) {
        return $c->NEXT::error(@_);
    }

    if ( $_[0] =~ /^(Unknown resource|No default action defined)/ ) {
        $c->response->status(404);
    }
    
    if ( $_[0] =~ /^Couldn\'t forward/ ) {
        $c->response->status(404);
    }    

    if ( $_[0] =~ /^Caught exception/ ) {
        $c->response->status(500);
    }

    my $error = $_[0];
    $error =~ s/\n/, /g;

    $c->response->headers->push_header( 'X-Catalyst-Error' => $error );

    $c->NEXT::error(@_);
}

1;
