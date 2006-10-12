package Nameless::Facet::MaxLength;

use strict;
use warnings;
use base 'Nameless::Facet';

use Return::Value qw[failure];

sub name {
    return 'max_length';
}

sub check {
    my ( $self, $value ) = @_;

    my $max = $self->value;

    return 1 unless defined $max;
    return 1 if length $$value <= $max;

    return failure string => "is longer than maximum $max characters.",
                   data   => [ '[_1] is longer than maximum [quant,_2,character].', $max ];
}

1;
