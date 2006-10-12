package Nameless::Facet::MinExclusive;

use strict;
use warnings;
use base 'Nameless::Facet';

use Return::Value qw[failure];

sub name {
    return 'min_exclusive';
}

sub check {
    my ( $self, $value ) = @_;

    my $min = $self->value;

    return 1 unless defined $min;
    return 1 if $$value > $min;

    return failure string => "is below minimum allowed, $min.",
                   data   => [ '[_1] is below minimum allowed, [_2].', $min ];
}

1;
