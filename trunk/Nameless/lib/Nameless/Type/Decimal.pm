package Nameless::Type::Decimal;

use strict;
use warnings;
use base 'Nameless::Type';

use Return::Value qw[success failure];

__PACKAGE__->new(
    name      => 'decimal',
    primitive => 1,
    facets    => [
        Nameless::Facet::WhiteSpace->new( value => 'collapse' ),
        Nameless::Facet::CallBack->new( value => \&_callback ),
        Nameless::Facet::Enumeration->new,
        Nameless::Facet::Pattern->new,
        Nameless::Facet::MinInclusive->new,
        Nameless::Facet::MinExclusive->new,
        Nameless::Facet::MaxInclusive->new,
        Nameless::Facet::MaxExclusive->new,
        Nameless::Facet::TotalDigits->new,
        Nameless::Facet::FractionDigits->new
    ]
)->register;

sub _callback {
    my ( $value ) = @_;

    return 1 if defined $$value && $$value =~ qr/^[+-]?\d+(?:\.\d+)?$/;

    return failure string => "is not a valid decimal.",
                   data   => [ '[_1] is not a valid decimal.' ];
}

1;
