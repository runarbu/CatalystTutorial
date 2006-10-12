### Dispatch based xmlrpc server ###
package TestApp;

use strict;
use Catalyst qw[Server Server::XMLRPC];
use base qw[Catalyst];

our $VERSION = '0.01';

### XXX make config configurable, so we can test the xmlrpc 
### specific config settings
TestApp->config( 
);

TestApp->setup;

### accept every xmlrpc request here
sub my_dispatcher : XMLRPCRegex('.') {
    my( $self, $c ) = @_;

    ### return the name of the method you called    
    $c->stash->{'xmlrpc'} = $c->request->xmlrpc->method;
}

1;
