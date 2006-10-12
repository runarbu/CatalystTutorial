package TestApp;

use strict;
use Catalyst qw/I18N/;

our $VERSION = '0.01';

TestApp->config( name => 'TestApp', root => '/some/dir' );

TestApp->setup;

sub maketext : Global {
    my( $self, $c, $key ) = @_;
    $c->res->body( $c->localize( $key ) );
}

sub current_language : Global {
    my( $self, $c ) = @_;
    $c->res->body( $c->language );
}

1;