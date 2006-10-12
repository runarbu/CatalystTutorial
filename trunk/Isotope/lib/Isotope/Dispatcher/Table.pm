package Isotope::Dispatcher::Table;

use strict;
use warnings;
use base 'Isotope::Dispatcher';

use File::Spec          qw[];
use File::Spec::Unix    qw[];
use Isotope::Exceptions qw[throw_dispatcher];
use Moose               qw[has];

has 'table'  => ( isa       => 'HashRef',
                  is        => 'ro',
                  required  => 1,
                  default   => sub { {} } );

sub setup {
    my $self = shift;

    foreach my $mount ( $self->mounts ) {
        my $dispatcher = $self->get_mount($mount);
        $dispatcher->application( $self->application );
        $dispatcher->setup;
    }
}

sub dispatch {
    my ( $self, $transaction, $path ) = @_;

    my ( $base, $dispatcher ) = $self->find_mount($path)
      or throw_dispatcher message => qq/Could not find a dispatcher for path '$path'./,
                          status  => 404;

    $path =~ s/^\Q$base\E//;

    return $dispatcher->dispatch( $transaction, $path );
}

sub mount {
    my ( $self, $path, $dispatcher ) = @_;

    $path = File::Spec::Unix->catdir( '/', $path );

    $self->set_mount( $path => $dispatcher );
}

sub find_mount {
    my ( $self, $path ) = @_;

    my @components = File::Spec::Unix->splitdir($path);

    while ( @components ) {

        my $path = File::Spec::Unix->catdir( @components );

        if ( $self->has_mount($path) ) {
            return ( $path, $self->get_mount($path) );
        }

        pop @components;
    }

    return ();
}

sub get_mount {
    my ( $self, $path ) = @_;
    return $self->table->{ $path };
}

sub set_mount {
    my ( $self, $path, $dispatcher ) = @_;
    $self->table->{ $path } = $dispatcher;
}

sub has_mount {
    my ( $self, $path ) = @_;
    return exists $self->table->{ $path };
}

sub mounts {
    my $self = shift;
    return sort keys %{ $self->table };
}

1;

__END__

