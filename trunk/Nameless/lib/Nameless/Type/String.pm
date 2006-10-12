package Nameless::Type::String;

use strict;
use warnings;
use base 'Nameless::Type';

use Return::Value qw[success failure];

__PACKAGE__->new(
    name      => 'string',
    primitive => 1,
    facets    => [
        Nameless::Facet::CallBack->new( value => \&_callback ),
        Nameless::Facet::WhiteSpace->new,
        Nameless::Facet::Length->new,
        Nameless::Facet::MinLength->new,
        Nameless::Facet::MaxLength->new,
        Nameless::Facet::Pattern->new,
        Nameless::Facet::Enumeration->new
    ]
)->register;

sub _callback {
    my ( $value ) = @_;

    return 1 if defined $$value;

    return failure string => "is not a valid string.",
                   data   => [ '[_1] is not a valid string.' ];
}

1;
