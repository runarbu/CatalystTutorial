package TestApp;

use strict;
use warnings;
use Catalyst;

our $VERSION = '0.01';

TestApp->config(
    name => 'TestApp',
);

TestApp->setup( qw/Scheduler/ );

sub default : Private {
    my ( $self, $c ) = @_;
    
    $c->res->output( 'default' );
}

1;

