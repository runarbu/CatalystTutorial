package HTML::Widget::Element::Reset;

use warnings;
use strict;
use base 'HTML::Widget::Element';
use NEXT;

__PACKAGE__->mk_accessors(qw/value/);

# alias
*label = \&value;

=head1 NAME

HTML::Widget::Element::Reset - Reset Element

=head1 SYNOPSIS

    $e = $widget->element( 'Reset', 'foo' );
    $e->value('bar');

=head1 DESCRIPTION

Reset Element.

=head1 METHODS

=head2 value

=head2 label

The value of this Reset element. Is also used by the browser as the 
button label.

If not set, the browser will usually display the label as "Reset".

=head2 $self->containerize( $widget, $value )

=cut

sub containerize {
    my ( $self, $w, $value ) = @_;

    $value ||= $self->value;
    my $i = $self->mk_input( $w, { type => 'reset', value => $value } );

    return $self->container( { element => $i } );
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
