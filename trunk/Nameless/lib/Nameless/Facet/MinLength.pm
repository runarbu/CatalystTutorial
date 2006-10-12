package Nameless::Facet::MinLength;

use strict;
use warnings;
use base 'Nameless::Facet';

use Return::Value qw[failure];

sub name {
    return 'min_length';
}

sub check {
    my ( $self, $value ) = @_;

    my $min = $self->value;

    return 1 unless defined $min;
    return 1 if length $$value >= $min;

    return failure string => "is shorter than minimum $min characters.",
                   data   => [ '[_1] is shorter than minimum [quant,_2,character].', $min ];
}

1;
