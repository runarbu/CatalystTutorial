package TestApp;

use strict;
use Catalyst;
use Data::Dumper;

our $VERSION = '0.01';

TestApp->config(
    name => 'TestApp',
    cache => {
        storage => "$FindBin::Bin/cache.dat",
    },
);

# Fail gracefully if we don't have FastMmap
my @plugins = ();
eval { 
    require Catalyst::Plugin::Cache::FastMmap; 
};
unless ($@) {
    push @plugins, qw/UploadProgress Cache::FastMmap/;
}
TestApp->setup( @plugins );
        
sub upload : Local {
    my ( $self, $c ) = @_;
    
    $c->res->output( 'ok' );
}

1;