package Nameless::Element;

use strict;
use warnings;
use base 'Nameless::Element::Base';

use Carp qw[];

__PACKAGE__->mk_attributes({

    # core attributes

    id => {
        type     => Params::Validate::SCALAR,
        optional => 1
    },
    class => {
        type     =>   Params::Validate::SCALAR
                    | Params::Validate::ARRAYREF,
        optional => 1
    },
    style => {
        type     => Params::Validate::SCALAR,
        optional => 1
    },
    title => {
        type     => Params::Validate::SCALAR,
        optional => 1
    },

    # i18n attributes

    lang => {
        type     => Params::Validate::SCALAR,
        optional => 1
    },
    dir => {
        type     => Params::Validate::SCALAR,
        optional => 1
    }

});

sub style {
    my $self = shift;

    if ( @_ == 0 ) {

        unless ( $self->hasAttribute('style') ) {
            return wantarray ? () : undef;
        }

        unless ( wantarray ) {
            return $self->getAttribute('style');
        }

        my %properties = ();
        my $style      = $self->getAttribute('style');

        # shamelessly borrowed from CSS::Tiny
        foreach ( grep { /\S/ } split /\;/, $style ) {

    		unless ( /^\s*([\w._-]+)\s*:\s*(.*?)\s*$/ ) {
    			Carp::croak( "Invalid or unexpected property '$_' in style '$style'" );
    		}

    		$properties{ lc $1 } = $2;
    	}

        return %properties;
    }

    if ( @_ == 1 ) {

        if ( defined $_[0] ) {
            $self->setAttribute( 'style' => $_[0] );
        }
        else {
            $self->removeAttribute('style');
        }
    }
    else {

        my @properties;

        while ( my ( $property, $value ) = splice( @_, 0, 2 ) ) {
            
            $property =~ tr/_/-/;
            
            push( @properties, sprintf( "%s:%s", $property, $value ) );
        }

        $self->setAttribute( 'style' => join( '; ', @properties ) );
    }

    return $self;
}

1;
