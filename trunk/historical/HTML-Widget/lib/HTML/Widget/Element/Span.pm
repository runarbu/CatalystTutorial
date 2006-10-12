package HTML::Widget::Element::Span;

use warnings;
use strict;
use base 'HTML::Widget::Element';

__PACKAGE__->mk_accessors(qw/content/);

=head1 NAME

HTML::Widget::Element::Span - Span Element

=head1 SYNOPSIS

    my $e = $widget->element( 'Span', 'foo' );
    $e->content('bar');

=head1 DESCRIPTION

Span Element.

=head1 METHODS

=head2 $self->containerize( $widget, $value )

=cut

sub containerize {
    my ( $self, $w ) = @_;

    my $content = $self->content;
    $self->attributes->{class} ||= 'span';
    my $e = HTML::Element->new( 'span', id => $self->id($w) );
    $e->push_content($content) if $content;
    $e->attr( $_ => ${ $self->attributes }{$_} )
      for ( keys %{ $self->attributes } );

    return $self->container( { element => $e } );
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
