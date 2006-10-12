package Nameless::Facet::FractionDigits;

use strict;
use warnings;
use base 'Nameless::Facet';

use Return::Value qw[failure];

sub name {
    return 'fraction_digits';
}

sub check {
    my ( $self, $value ) = @_;

    my $fdigits = $self->value;

    return 1 unless defined $fdigits;

    # strip leading and trailing zeros for numeric constraints
    ( my $digits = $$value ) =~ s/^([+-]?)0*(\d*\.?\d*?)0*$/$1$2/g;

    return 1 if $digits !~ /\.\d{$fdigits}\d/;

    return failure string => "has more fraction digits than allowed, $fdigits.",
                   data   => [ '[_1] has more fraction digits than allowed, [_2].', $fdigits ];
}

1;
