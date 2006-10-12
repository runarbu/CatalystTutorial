package Nameless::Element::Legend;

use strict;
use warnings;
use base 'Nameless::Element';

__PACKAGE__->mk_element('legend');
__PACKAGE__->mk_attributes({
    accesskey => {
        type     => Params::Validate::SCALAR,
        optional => 1        
    },
    value => {
        type     => Params::Validate::SCALAR,
        optional => 1  
    }
});

sub value {
    my $self = shift;
    
    if ( @_ == 0 ) {
        
        my $value;
        
        if ( $self->hasChildNodes && $self->firstChild->nodeType == 3 ) {
            $value = $self->firstChild->nodeValue;
        }

        return $value;
    }
    
    if ( @_ == 1 ) {
        
        if ( defined $_[0] ) {
            
            my $value = XML::LibXML::Text->new( $_[0] );
            
            if ( $self->hasChildNodes ) {
                
                if ( $self->firstChild->nodeType == 3 ) {
                    $self->replaceChild( $value, $self->firstChild );
                }
                else {
                    $self->removeChildNodes;
                    $self->appendChild( $value );
                }
            }
            else {
                $self->appendChild( $value );
            }
        }
        else {
            $self->removeChildNodes;
        }
        
        return $self;
    }
}

1;
