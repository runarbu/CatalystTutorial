package Nameless::Element::Label;

use strict;
use warnings;
use base 'Nameless::Element';

use Carp         qw[];
use Scalar::Util qw[blessed];

__PACKAGE__->mk_element('label');
__PACKAGE__->mk_attributes({
    accesskey => {
        type     => Params::Validate::SCALAR,
        optional => 1
    },
    for => {
        type     =>   Params::Validate::SCALAR
                    | Params::Validate::OBJECT,
        optional => 1
    },
    value => {
        type     => Params::Validate::SCALAR,
        optional => 1
    }
});

sub for {
    my $self = shift;

    if ( @_ == 0 ) {
        return $self->getAttribute('for');
    }

    if ( @_ == 1 ) {

        if ( defined $_[0] ) {

            my $for = shift;

            if ( blessed $for && $for->isa('XML::LibXML::Element') ) {

                unless ( $for->hasAttribute('id') ) {
                    Carp::croak qq/Can't associate label for control. Control has no id attribute./;
                }

                $for = $for->getAttribute('id');
            }

            $self->setAttribute( 'for' => $for );
        }
        else {
            $self->removeAttribute('for');
        }

        return $self;
    }
}

sub value {
    my $self = shift;

    if ( @_ == 0 ) {

        my $value;

        if ( $self->hasChildNodes ) {

            if ( $self->firstChild->nodeType == 3 ) {
                $value = $self->firstChild->nodeValue;
            }

            elsif ( $self->lastChild->nodeType == 3 ) {
                $value = $self->lastChild->nodeValue;
            }
        }

        return $value;
    }

    if ( @_ == 1 ) {

        # http://www.w3.org/TR/html401/interact/forms.html#h-17.9.1
        # XXX make this more robust

        if ( defined $_[0] ) {

            my $value = XML::LibXML::Text->new( $_[0] );

            if ( $self->hasChildNodes ) {

                if ( $self->firstChild->nodeType == 3 ) {
                    $self->replaceChild( $value, $self->firstChild );
                }
                elsif ( $self->lastChild->nodeType == 3 ) {
                    $self->replaceChild( $value, $self->lastChild );
                }
                else {
                    $self->insertBefore( $value, $self->firstChild );
                }
            }
            else {
                $self->appendChild( $value );
            }
        }
        else {

            if ( $self->hasChildNodes ) {

                if ( $self->firstChild->nodeType == 3 ) {
                    $self->removeChild( $self->firstChild );
                }

                elsif ( $self->lastChild->nodeType == 3 ) {
                    $self->removeChild( $self->lastChild );
                }
            }
        }

        return $self;
    }
}

1;
