package Nameless::Facet::WhiteSpace;

use strict;
use warnings;
use base 'Nameless::Facet';

use Return::Value qw[failure];

sub name {
    return 'white_space';
}

sub check {
    my ( $self, $value ) = @_;

    my $ws = $self->value;

    return 1 unless defined $ws;
    return 1 if $ws eq 'preserve';

    if ( $ws eq 'replace' || $ws eq 'collapse' ) {
        $$value =~ s![\t\n\r]! !g;
    }

    if ( $ws eq 'collapse' ) {
        $$value =~ s!\s+! !g;
        $$value =~ s!^\s!!g;
        $$value =~ s!\s$!!g;
    }

    return 1;
}

1;
