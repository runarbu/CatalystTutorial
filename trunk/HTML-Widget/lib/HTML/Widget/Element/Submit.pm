package HTML::Widget::Element::Submit;

use warnings;
use strict;
use base 'HTML::Widget::Element';
use NEXT;

__PACKAGE__->mk_accessors(qw/value src height width retain_default/);

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

L</label> is an alias for L</value>.

=head2 src

If set, the element will be an image submit, using this url as image.

=head2 height

Only used if L</src> is set.

Sets the height the image submit button should be rendered.

=head2 width

Only used if L</src> is set.

Sets the width the image submit button should be rendered.

=head2 retain_default

If true, overrides the default behaviour, so that after a field is missing 
from the form submission, the xml output will contain the default value, 
rather than be empty.

=head2 containerize

=cut

sub containerize {
    my ( $self, $w, $value, $errors, $args ) = @_;

    $value = ref $value eq 'ARRAY' ? shift @$value : $value;

    $value = $self->value
        if ( not defined $value )
        and $self->retain_default || not $args->{submitted};

    my $i;
    if ( $self->src ) {
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

=head1 SEE ALSO

L<HTML::Widget::Element>

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
