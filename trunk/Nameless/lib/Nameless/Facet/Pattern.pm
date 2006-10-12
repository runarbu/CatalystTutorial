package Nameless::Facet::Pattern;

use strict;
use warnings;
use base 'Nameless::Facet';

use Return::Value qw[failure];

sub name {
    return 'pattern';
}

sub check {
    my ( $self, $value ) = @_;

    my $patterns = $self->value;

    return 1 unless defined $patterns;
    
    unless ( ref $patterns eq 'ARRAY' ) {
        $patterns = [ $patterns ];
    }    

    foreach my $pattern ( @$patterns ) {
        return 1 if $$value =~ /$pattern/;
    }

    return failure string => "does not match required pattern.",
                   data   => [ '[_1] does not match required pattern.' ];
}

1;
