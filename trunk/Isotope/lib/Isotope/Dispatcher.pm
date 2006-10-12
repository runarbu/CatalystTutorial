package Isotope::Dispatcher;

use strict;
use warnings;
use base 'Isotope::Object';

use File::Spec       qw[];
use File::Spec::Unix qw[];
use Moose            qw[has];

has 'application' => ( isa       => 'Isotope::Application',
                       is        => 'rw',
                       weak_ref  => 1,
                       trigger   => sub {
                           my ( $self, $application ) = @_;

                           unless ( $self->has_log ) {
                               $self->log( $application->construct_log($self) );
                           }
                       });

has 'log'         => ( isa       => 'Object',
                       is        => 'rw',
                       predicate => 'has_log' );

sub setup { 1 }

1;
