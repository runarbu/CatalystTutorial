package Nameless::Library;

use strict;
use warnings;

use Carp qw[];

sub new {
    my $class = ref $_[0] ? ref shift : shift;
    return bless( { @_ }, $class );
}

sub get {
    my ( $self, $name ) = @_;
    return $self->{ lc $name };
}

sub set {
    my ( $self, $type ) = @_;
    return $self->{ lc $type->name } = $type;
}

sub names {
    return keys %{ $_[0] };
}

sub types {
    return values %{ $_[0] };
}

sub add {
    my $self = shift;
    my $type = shift;
    my $name = $type->name;

    $self->has($name)
      and Carp::croak qq/Illegal attempt to redifine type '$name'/;

    $type->is_anonymous
      and Carp::croak qq/Illegal attempt to register an anonymous derived type./;

    $self->set($type);
}

sub has {
    my ( $self, $name ) = @_;
    return $self->{ lc $name } ? 1 : 0;
}

sub clone {
    return $_[0]->new( %{ $_[0] } );
}

1;
