package Nameless::Type::Integer;

use strict;
use warnings;
use base 'Nameless::Type';

use Return::Value qw[success failure];

__PACKAGE__->new(
    name      => 'integer',
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

    return 1 if defined $$value && $$value =~ qr/^[+-]?\d+$/;

    return failure string => "is not a valid integer.",
                   data   => [ '[_1] is not a valid integer.' ];
}

1;
