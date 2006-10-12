package Nameless::Type;

use strict;
use warnings;
use base 'Exporter';

use Carp              qw[];
use List::Util        qw[first];
use Params::Validate  qw[];
use Return::Value     qw[success failure];
use Nameless::Facet   qw[];
use Nameless::Library qw[];

our $LIBRARY = Nameless::Library->new;

sub import {
    my $class  = shift;
    my @import = ();
    my $caller = caller(0);

    while ( my $symbol = shift ) {

        no strict 'refs';

        if ( $symbol eq 'library' ) {

            *{"$caller\::library"} = sub () {
                return $LIBRARY
            };
        }
        elsif ( $symbol eq 'type' ) {

            *{"$caller\::type"} = sub ($) {
                return $LIBRARY->get(@_);
            };
        }
        else {
            push @import, $symbol;
        }
    }

    return $class->export_to_level( 1, @import );
}

sub new {
    my $class = ref $_[0] ? ref shift: shift;
    my $param = Params::Validate::validate_with(
        params => \@_,
        spec   => {
            name => {
                type     => Params::Validate::SCALAR,
                optional => 1
            },
            primitive => {
                type     => Params::Validate::SCALAR,
                default  => 0,
                optional => 1
            },            
            base => {
                type     => Params::Validate::OBJECT,
                isa      => 'Nameless::Type',
                optional => 1
            },
            facets => {
                type     => Params::Validate::ARRAYREF,
                optional => 0
            }
        },
        called => "$class\::new",
    );

    return bless( $param, $class );
}

sub register {
    return $LIBRARY->add( $_[0] );
}

sub base {
    return $_[0]->{base};
}

sub facets {
    return wantarray ? @{ $_[0]->{facets} } : $_[0]->{facets};
}

sub name {
    return $_[0]->{name};
}

sub derive {
    my $self = shift;

    return $self->new( @_,
        base   => $self,
        facets =>[ map { $_->clone } $self->facets ]
    );
}

sub root {
    my $self  = shift;
    my $super = $self;

    while ( $super->base ) {
        $super = $super->base;
    }

    return $super;
}

sub constrain {
    my $self = shift;
    
    Carp::croak qq/Illegal attempt to constrain a primitive type./
      if $self->is_primitive;

    while ( my ( $name, $value ) = splice( @_, 0, 2 ) ) {

        my $facet = first { $name eq $_->name } $self->facets
          or Carp::croak qq/Unknown constraining facet '$name'./;

        $facet->value($value);
    }

    return $self;
}

sub check {
    my ( $self, $value ) = @_;
    return $self->_check(\$value);
}

sub _check {
    my ( $self, $value ) = @_;

    my $result;

    if ( $self->base ) {

        $result = $self->base->_check($value)
          or return $result;
    }

    foreach my $facet ( $self->facets ) {

        $result = $facet->check($value)
          or return $result;
    }

    return success string => $$value;
}

sub is_primitive {
    return $_[0]->{primitive};
}

sub is_anonymous {
    return 0 if defined $_[0]->name;
    return 1;
}

# XXX circular dependency, refactor

require Nameless::Type::Boolean;
require Nameless::Type::Decimal;
require Nameless::Type::Integer;
require Nameless::Type::String;

1;

__END__

=head1 NAME

Nameless::Type - Type

=head1 SYNOPSIS

    use Nameless::Type 'type';

    my $currency = type('string')->derive->constrain(
        length  => 3,
        pattern => qr/^[A-Z]{3}$/
    );

    print $currency->check('USD');

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item new

=item base

=item root

=item facets

=item derive

=item constrain

=item check

=item is_anonymous

=item is_primitive

=back

=head1 FACETS

=over 4

=item Length

=item Max Length

=item Min Length

=item Pattern

=item Enumeration

=item Min Inclusive

=item Max Inclusive

=item Min Exclusive

=item Max Exclusive

=item Total Digits

=item Fraction Digits

=item White Space

=back

=head1 SEE ALSO

L<Nameless::Type::Boolean>.

L<Nameless::Type::Decimal>.

L<Nameless::Type::Integer>.

L<Nameless::Type::String>.

=head1 AUTHOR

Christian Hansen C<ch@ngmedia.com>

=head1 COPYRIGHT

Parts of this code was derived from XML::Validator::Schema which is copyrighted
by Sam Tregar.

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
