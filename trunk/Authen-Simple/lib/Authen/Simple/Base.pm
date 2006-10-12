package Authen::Simple::Base;

use strict;
use warnings;
use base qw[Class::Accessor::Fast Class::Data::Inheritable];

use Params::Validate qw[HASHREF];

__PACKAGE__->mk_classdata( _options => { } );

sub new {
    my $class = ref $_[0] ? ref shift : shift;

    my $params = Params::Validate::validate_with(
        params => \@_,
        spec   => $class->options,
        called => "$class\::new"
    );

    return $class->SUPER::new->init($params);
}

sub init {
    my ( $self, $params ) = @_;

    while ( my ( $method, $value ) = each( %{ $params } ) ) {
        $self->$method($value);
    }

    return $self;
}

sub options {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    if ( @_ ) {

        my ($options) = Params::Validate::validate_pos( @_, { type => HASHREF } );

        if ( my @create = grep { ! $class->can($_) } keys %{ $options } ) {
            $class->mk_accessors(@create);
        }

        while ( my ( $option, $spec ) = each( %{ $class->_options } ) ) {
            $options->{ $option } = $spec;
        }

        $class->_options($options);
    }

    return $class->_options;
}

1;
