package Nameless::Element::Base;

BEGIN {
    require XML::LibXML;
}

use strict;
use warnings;
use base qw[XML::LibXML::Element Class::Data::Inheritable];
use overload '""' => \&toString, fallback => 1;

use Carp             qw[];
use Params::Validate qw[ BOOLEAN ARRAYREF HASHREF ];

__PACKAGE__->mk_classdata( __attributes => {} );
__PACKAGE__->mk_classdata( __element    => '' );

sub new {
    my $class      = ref $_[0] ? ref shift : shift;
    my $element    = $class->__element || shift;
    my $attributes = Params::Validate::validate_with(
        params  => \@_,
        spec    => $class->__attributes,
        called  => "$class\::new",
    );

    return bless( $class->SUPER::new($element), $class )->initialize( $attributes );
}

sub initialize {
    my ( $self, $attributes ) = @_;

    while ( my ( $attribute, $value ) = each( %{ $attributes } ) ) {
        $self->$attribute($value);
    }

    return $self;
}

sub mk_element {
    my ( $class, $element ) = @_;
    $class->__element($element);
}

sub mk_attributes {
    my $class = shift;

    my ( $attributes ) = Params::Validate::validate_with(
        params  => \@_,
        spec    => [ { type => Params::Validate::HASHREF } ],
        called  => "$class\::mk_attributes",
    );

    foreach my $method ( keys %{ $attributes } ) {

        next if $method eq 'element' || $class->can($method);

        my $attribute = $attributes->{ $method }->{ attribute } || lc $method;
        my $separator = $attributes->{ $method }->{ separator } || 'space';
        my $type      = $attributes->{ $method }->{ type      } || 0;

        if ( ( $type & BOOLEAN ) == BOOLEAN ) {
            $class->mk_boolean_attribute( $method, $attribute );
        }
        elsif ( ( $type & ARRAYREF ) == ARRAYREF ) {
            $class->mk_list_attribute( $method, $attribute, $separator );
        }
        else {
            $class->mk_attribute( $method, $attribute );
        }
    }

    while ( my ( $attribute, $spec ) = each( %{ $class->__attributes } ) ) {
        $attributes->{ $attribute } ||= $spec;
    }

    $class->__attributes($attributes);
}

sub mk_attribute {
    my ( $class, $method, $attribute ) = @_;

    no strict 'refs';

    *$method = sub {
        my $self = shift;

        if ( @_ == 1 ) {

            if ( defined $_[0] ) {
                $self->setAttribute( $attribute => $_[0] );
            }
            else {
                $self->removeAttribute($attribute);
            }

            return $self;
        }

        return $self->getAttribute($attribute);
    };
}

sub mk_boolean_attribute {
    my ( $class, $method, $attribute ) = @_;

    no strict 'refs';

    *$method = sub {
        my $self = shift;

        if ( @_ == 1 ) {

            if ( defined $_[0] ) {
                $self->setAttribute( $attribute => $attribute );
            }
            else {
                $self->removeAttribute($attribute);
            }

            return $self;
        }

        return $self->hasAttribute($attribute) ? 1 : 0;
    };
}

my %lists = (
    comma => [ qr/\s*,\s*/,     ', ' ],
    space => [ qr/\s+/,         ' '  ],
    mixed => [ qr/\s+|\s*,\s*/, ', ' ]
);

sub mk_list_attribute {
    my ( $class, $method, $attribute, $separator ) = @_;

    Carp::croak qq/Invalid separator '$separator'./
      unless exists $lists{ $separator };

    my ( $split, $join ) = @{ $lists{ $separator } };
    
    no strict 'refs';

    *$method = sub {
        my $self = shift;

        if ( @_ == 0 ) {

            unless ( $self->hasAttribute($attribute) ) {
                return wantarray ? () : undef;
            }

            my $value = $self->getAttribute($attribute);

            return wantarray ? split( $split, $value ) : $value;
        }
        else {
            
            my @value = @_;
            
            if ( @value == 1 && ref $value[0] eq 'ARRAY' ) {
                @value = @{ $value[0] };
            }

            if ( @value == 1 ) {

                if ( defined $value[0] ) {
                    $self->setAttribute( $attribute => $value[0] );
                }
                else {
                    $self->removeAttribute($attribute);
                }
            }
            else {
                $self->setAttribute( $attribute => join( $join, @value ) );
            }

            return $self;
        }
    }
}

sub toString {
    no warnings 'uninitialized';
    return shift->SUPER::toString(2);
}

1;
