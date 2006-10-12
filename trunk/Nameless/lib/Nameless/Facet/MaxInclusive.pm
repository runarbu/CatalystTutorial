package Nameless::Facet::MaxInclusive;

use strict;
use warnings;
use base 'Nameless::Facet';

use Return::Value qw[failure];

sub name {
    return 'max_inclusive';
}

sub check {
    my ( $self, $value ) = @_;

    my $max = $self->value;

    return 1 unless defined $max;
    return 1 if $$value <= $max;

    return failure string => "is above maximum (inclusive) allowed, $max.",
                   data   => [ '[_1] is above maximum (inclusive) allowed, [_2].', $max ];
}

1;
