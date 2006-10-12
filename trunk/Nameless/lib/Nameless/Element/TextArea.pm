package Nameless::Element::TextArea;

use strict;
use warnings;
use base 'Nameless::Element';

__PACKAGE__->mk_element('textarea');
__PACKAGE__->mk_attributes({
    name => {
        type     => Params::Validate::SCALAR,
        optional => 1
    },
    value => {
        type     => Params::Validate::SCALAR,
        optional => 1        
    },
    rows => {
        type     => Params::Validate::SCALAR,
        default  => 20,
        optional => 1
    },
    cols => {
        type     => Params::Validate::SCALAR,
        default  => 40,
        optional => 1
    },
    disabled => {
        type     => Params::Validate::BOOLEAN,
        optional => 1
    },
    readonly => {
        type     => Params::Validate::BOOLEAN,
        optional => 1
    },
    tabindex => {
        type     => Params::Validate::SCALAR,
        optional => 1
    },
    accesskey => {
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
