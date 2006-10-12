package HTML::Widget::Element::Textarea;

use warnings;
use strict;
use base 'HTML::Widget::Element';
use HTML::Element;
use NEXT;

__PACKAGE__->mk_accessors(qw/comment label value/);
__PACKAGE__->mk_attr_accessors(qw/cols rows wrap/);

=head1 NAME

HTML::Widget::Element::Textarea - Textarea Element

=head1 SYNOPSIS

    my $e = $widget->element( 'Textarea', 'foo' );
    $e->comment('(Required)');
    $e->label('Foo');
    $e->cols(30);
    $e->rows(40);
    $e->value('bar');
    $e->wrap('wrap');

=head1 DESCRIPTION

Textarea Element.

=head1 METHODS

=head2 new

Create new textarea with default size of 20 rows and 40 columns

=cut

sub new {
    shift->NEXT::new(@_)->rows(20)->cols(40);
}

=head2 $self->containerize( $widget, $value, $errors )

=cut

sub containerize {
    my ( $self, $w, $value, $errors ) = @_;

    $value ||= $self->value;

    $value = ref $value eq 'ARRAY' ? shift @$value : $value;

    my $l = $self->mk_label( $w, $self->label, $self->comment, $errors );

    $self->attributes->{class} ||= 'textarea';
    my $i = HTML::Element->new('textarea');
    $i->push_content($value) if $value;
    my $id = $self->id($w);
    $i->attr( id   => $id );
    $i->attr( name => $self->name );

    $i->attr( $_ => ${ $self->attributes }{$_} )
      for ( keys %{ $self->attributes } );

    my $e = $self->mk_error( $w, $errors );

    return $self->container( { element => $i, error => $e, label => $l } );
}

=head2 label

=head2 value

=head2 cols

=head2 rows

=head2 wrap

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
