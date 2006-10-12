package HTML::Widget::Element::Submit;

use warnings;
use strict;
use base 'HTML::Widget::Element';
use NEXT;

__PACKAGE__->mk_accessors(qw/value src height width/);

# alias
*label = \&value;

=head1 NAME

HTML::Widget::Element::Submit - Submit Element

=head1 SYNOPSIS

    $e = $widget->element( 'Submit', 'foo' );
    $e->value('bar');

=head1 DESCRIPTION

Submit Element.

=head1 METHODS

=head2 value

=head2 label

The value of this Submit element. Is also used by the browser as the 
button label.

If not set, the browser will usually display the label as "Submit".

=head2 src

If set, the element will be an image submit, using this url as image.

=head2 height

Only used if L</src> is set.

Sets the height the image submit button should be rendered.

=head2 width

Only used if L</src> is set.

Sets the width the image submit button should be rendered.

=head2 $self->containerize( $widget, $value )

=cut

sub containerize {
    my ( $self, $w, $value ) = @_;

    $value = ref $value eq 'ARRAY' ? shift @$value : $value;

    $value ||= $self->value;
    my $i;
    if ($self->src) {
        my $args = { type => 'image', src => $self->src, value => $value };
        $args->{height} = $self->height() if defined $self->height;
        $args->{width}  = $self->width()  if defined $self->width;

        $i = $self->mk_input( $w, $args );
    }
    else {
        $i = $self->mk_input( $w, { type => 'submit', value => $value } );
    }

    return $self->container( { element => $i } );
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
