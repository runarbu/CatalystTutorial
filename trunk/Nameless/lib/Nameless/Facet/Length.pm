package Nameless::Facet::Length;

use strict;
use warnings;
use base 'Nameless::Facet';

use Return::Value qw[failure];

sub name {
    return 'length';
}

sub check {
    my ( $self, $value ) = @_;

    my $length = $self->value;

    return 1 unless defined $length;
    return 1 if length $$value == $length;

    return failure string => "is not exactly $length characters.",
                   data   => [ '[_1] is not exactly [quant,_2,character].', $length ];
}

1;
