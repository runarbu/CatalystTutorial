package Nameless::Facet::CallBack;

use strict;
use warnings;
use base 'Nameless::Facet';

use Return::Value qw[failure];

sub name {
    return 'callback';
}

sub check {
    my ( $self, $value ) = @_;

    my $callback = $self->value;

    return 1 unless defined $callback;
    return &$callback($value);
}

1;
