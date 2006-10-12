package Nameless::Facet::TotalDigits;

use strict;
use warnings;
use base 'Nameless::Facet';

use Return::Value qw[failure];

sub name {
    return 'total_digits';
}

sub check {
    my ( $self, $value ) = @_;

    my $tdigits = $self->value;

    return 1 unless defined $tdigits;

    # strip leading and trailing zeros for numeric constraints
    ( my $digits = $$value ) =~ s/^([+-]?)0*(\d*\.?\d*?)0*$/$1$2/g;

    return 1 if $digits =~ tr!0-9!! <= $tdigits;

    return failure string => "has more total digits than allowed, $tdigits.",
                   data   => [ '[_1] has more total digits than allowed, [_2].', $tdigits ];
}

1;
