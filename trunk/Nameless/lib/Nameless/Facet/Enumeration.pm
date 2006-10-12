package Nameless::Facet::Enumeration;

use strict;
use warnings;
use base 'Nameless::Facet';

use Return::Value qw[failure];

sub name {
    return 'enumeration';
}

sub check {
    my ( $self, $value ) = @_;

    my $enumeration = $self->value;

    return 1 unless defined $enumeration;
    
    unless ( ref $enumeration eq 'ARRAY' ) {
        $enumeration = [ $enumeration ];
    }

    foreach ( @$enumeration ) {
        return 1 if $_ eq $$value;
    }

    my $list = join ', ', @$enumeration;

    return failure string => "is not in allowed list ( $list ).",
                   data   => [ '[_1] is not in allowed list ( [_2] ).', $list ];
}

1;
