package Nameless::Type::Boolean;

use strict;
use warnings;
use base 'Nameless::Type';

use Return::Value qw[failure];

__PACKAGE__->new(
    name      => 'boolean',
    primitive => 1,
    facets    => [
        Nameless::Facet::WhiteSpace->new( value => 'collapse' ),
        Nameless::Facet::CallBack->new( value => \&_callback ),
        Nameless::Facet::Pattern->new,
    ]
)->register;

sub _callback {
    my ( $value ) = @_;

    return 1 if defined $$value && $$value =~ qr/^1|0|true|false$/;

    return failure string => "is not a valid boolean.",
                   data   => [ '[_1] is not a valid boolean.' ];
}

1;
