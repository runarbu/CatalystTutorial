package Upload::Controller::Upload;

use strict;
use base 'Catalyst::Base';
use Data::Dumper;

sub default : Private {
    my ( $self, $c ) = @_;
    
    $c->forward( 'form' );
}

# The form method displays the upload form 
sub form : Local {
    my ( $self, $c ) = @_;
    
    $c->stash->{template} = 'form.xhtml';
}

1;
