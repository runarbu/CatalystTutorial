package Nameless::Facet;

use strict;
use warnings;

use Params::Validate qw[];

use Nameless::Facet::CallBack;
use Nameless::Facet::Enumeration;
use Nameless::Facet::FractionDigits;
use Nameless::Facet::Length;
use Nameless::Facet::MaxExclusive;
use Nameless::Facet::MaxInclusive;
use Nameless::Facet::MaxLength;
use Nameless::Facet::MinExclusive;
use Nameless::Facet::MinInclusive;
use Nameless::Facet::MinLength;
use Nameless::Facet::Pattern;
use Nameless::Facet::TotalDigits;
use Nameless::Facet::WhiteSpace;

sub new {
    my $class = ref $_[0] ? ref shift : shift;
    my $param = Params::Validate::validate_with(
        params => \@_,
        spec   => {
            value => {
                type     =>   Params::Validate::ARRAYREF
                            | Params::Validate::CODEREF
                            | Params::Validate::SCALAR,
                optional => 1
            }
        },
        called => "$class\::new",
    );

    return bless( [], $class )->initialize($param);
}

sub initialize {
    my ( $self, $params ) = @_;

    while ( my ( $param, $value ) = each %{ $params } ) {
        $self->$param($value);
    }

    return $self;
}

sub value {
    my $self = shift;

    if ( @_ ) {
        $self->[0] = shift;
        return $self;
    }

    return $self->[0];
}

sub clone {
    my $self  = shift;
    my $clone = $self->new;
    my $value = $self->value;
    
    if ( ref $value eq 'ARRAY' ) {
        $value = [ @$value ];
    }
    
    $clone->value($value) if defined $value;
    
    return $clone;
}

1;
