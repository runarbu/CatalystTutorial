package Isotope::Plugin;

use strict;
use warnings;
use base 'Isotope::Object';

use constant DECLINED => 0x0100;
use constant DONE     => 0x0200;
use constant OK       => 0x0400;

use Sub::Exporter( 
    -setup => { 
        exports => [ qw( DECLINED DONE OK ) ] 
    } 
);

use Isotope::Exceptions qw[throw_plugin];
use Moose               qw[has];

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

sub register { }

sub engine {
    return $_[0]->application->engine;
}

1;

__END__
