package Isotope::Dispatcher::Callback;

use strict;
use warnings;
use base 'Isotope::Dispatcher';

use Isotope::Exceptions qw[throw_dispatcher];
use Moose               qw[has];

has 'callback'  => ( isa      => 'CodeRef',
                     is       => 'ro',
                     required => 1 );

sub dispatch {
    my ( $self, $t, $path, @arguments ) = @_;

    eval {
        &{ $self->callback }( $self, $t, $path, @arguments );
    };

    if ( $@ ) {

        if ( Exception::Class::Base->caught ) {
            $@->rethrow;
        }

        throw_dispatcher message => qq/Could not execute dispatcher callback./,
                         payload => $@;
    }
}

1;
