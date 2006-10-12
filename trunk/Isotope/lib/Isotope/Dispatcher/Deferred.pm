package Isotope::Dispatcher::Deferred;

use strict;
use warnings;
use prefork;
use base 'Isotope::Dispatcher';

use Isotope::Exceptions qw[throw_dispatcher];
use Moose               qw[has];

# Public Attributes

has 'class'       => ( isa       => 'Str',
                       is        => 'ro',
                       required  => 1 );

has 'method'      => ( isa       => 'Str',
                       is        => 'ro',
                       required  => 1,
                       default   => 'dispatch' );

has 'constructor' => ( isa       => 'Str',
                       is        => 'ro',
                       required  => 1,
                       default   => 'new' );

has 'arguments'   => ( isa       => 'CollectionRef',
                       is        => 'ro',
                       predicate => 'has_arguments' );

has 'instantiate' => ( isa       => 'Bool',
                       default   => 1,
                       reader    => 'should_instantiate' );

has 'destroy'     => ( isa       => 'Bool',
                       default   => 1,
                       reader    => 'should_destroy' );

has 'prefork'     => ( isa       => 'Bool',
                       default   => 1,
                       reader    => 'should_prefork' );

# Protected Attributes

has 'instance'    => ( isa       => 'Object',
                       is        => 'rw',
                       predicate => 'has_instance' );

has 'initialized' => ( isa       => 'Bool',
                       is        => 'rw',
                       default   => 0,
                       reader    => 'is_initialized' );

sub BUILD {
    my ( $self, $params ) = @_;

    if ( $self->should_prefork ) {
        prefork::prefork( $self->class );
    }
}

sub dispatch {
    my ( $self, @parameters ) = @_;

    my $constructor = $self->constructor;
    my $class       = $self->class;
    my $method      = $self->method;
    my $thing       = $class;

    if ( !$self->is_initialized ) {

        throw_dispatcher message => qq/Could not load dispatcher class '$class'./,
                         payload => $@
          if !eval "require $class;";

        throw_dispatcher qq/Dispatcher class '$class' does not have a constructor named '$constructor'./
          if $self->should_instantiate && !$class->can($constructor);

        throw_dispatcher qq/Dispatcher class '$class' does not have a dispatch method named '$method'./
          if !$class->can($method);

        $self->initialized(1);
    }

    if ( $self->should_instantiate ) {

        if ( $self->has_instance ) {
            $thing = $self->instance;
        }
        else {

            my @arguments = ();

            if ( $self->has_arguments ) {

                if ( ref $self->arguments eq 'ARRAY' ) {
                    @arguments = @{ $self->arguments };
                }

                if ( ref $self->arguments eq 'HASH' ) {
                    @arguments = %{ $self->arguments };
                }
            }

            eval {
                $thing = $class->$constructor(@arguments);
            };

            if ( $@ ) {

                if ( Exception::Class::Base->caught ) {
                    $@->rethrow;
                }

                throw_dispatcher message => qq/Could not instantiate dispatcher class '$class'./,
                                 payload => $@;
            }

            if ( $thing->isa('Isotope::Dispatcher') ) {
                $thing->application( $self->application );
                $thing->setup;
            }

            if ( !$self->should_destroy ) {
                $self->instance($thing);
            }
        }
    }

    if ( !$thing->isa('Isotope::Dispatcher') ) {
        unshift @parameters, $self;
    }

    eval {
        $thing->$method(@parameters);
    };

    if ( $@ ) {

        if ( Exception::Class::Base->caught ) {
            $@->rethrow;
        }

        throw_dispatcher message => qq/Could not call dispatch method '$method' on class '$class'./,
                         payload => $@;
    }
}

1;
