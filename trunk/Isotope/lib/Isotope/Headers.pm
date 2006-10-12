package Isotope::Headers;

BEGIN {
    require HTTP::Headers;
    require HTTP::Headers::ETag;
}

use strict;
use warnings;
use base 'HTTP::Headers';
use prefork 'HTTP::Date';

use Isotope::Exceptions qw[throw_param];
use Scalar::Util        qw[blessed];

BEGIN {
    *get         = __PACKAGE__->can('header');
    *set         = __PACKAGE__->can('header');
    *add         = __PACKAGE__->can('push_header');
    *remove      = __PACKAGE__->can('remove_header');
    *field_names = __PACKAGE__->can('header_field_names');
}

sub new {
    my $class = ref $_[0] ? ref shift : shift;

    if ( @_ == 1 ) {
        return $class->SUPER::new->merge(@_);
    }

    unless ( @_ % 2 == 0 ) {
        throw_param qq/Odd number of header fields given to constructor./;
    }

    return $class->SUPER::new(@_);
}

sub has {
    my ( $self, $field ) = @_;
    $field =~ tr/_/-/ if $field !~ /^:/ && $HTTP::Headers::TRANSLATE_UNDERSCORE;
    return exists $self->{ lc $field };
}

sub clone {
    my $self  = shift;
    my $clone = $self->new;
    $self->scan( sub { $clone->add(@_); } );
    return $clone;
}

sub merge {
    my ( $self, $source ) = @_;

    if ( blessed $source && $source->isa('HTTP::Headers') ) {
        $source->scan( sub { $self->add(@_); } );
    }
    elsif ( ref $source eq 'HASH' ) {
        $self->add( $_ => $source->{ $_ } ) for keys %{ $source };
    }
    elsif ( ref $source eq 'ARRAY' ) {

        unless ( @{ $source } % 2 == 0 ) {
            throw_param qq/Odd number of header fields in ARRAY./;
        }

        for ( my $i = 0; $i < @{ $source }; $i += 2 ) {
            $self->add( $source->[ $i ] => $source->[ $i + 1 ] );
        }
    }
    else {
        throw_param qq/Can't merge a '$source'./;
    }

    return $self;
}

sub as_string {
    my ( $self, $eol ) = @_;
    return $self->SUPER::as_string( defined $eol ? $eol : "\x0d\x0a" );
}

1;

__END__

=head1 NAME

Isotope::Headers - Isotope Headers Class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item new

=item get

=item set

=item add

=item has

=item merge

=item clone

=back

=head1 SEE ALSO

L<HTTP::Headers>.

=head1 AUTHOR

Christian Hansen C<ch@ngmedia.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
