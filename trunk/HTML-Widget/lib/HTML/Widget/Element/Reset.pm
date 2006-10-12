package HTML::Widget::Element::Reset;

use warnings;
use strict;
use base 'HTML::Widget::Element';
use NEXT;

__PACKAGE__->mk_accessors(qw/value retain_default/);

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

L</label> is an alias for L</value>.

=head2 retain_default

If true, overrides the default behaviour, so that after a field is missing 
from the form submission, the xml output will contain the default value, 
rather than be empty.

=head2 containerize

=cut

sub containerize {
    my ( $self, $w, $value, $errors, $args ) = @_;

    $value = $self->value
        if ( not defined $value )
        and $self->retain_default || not $args->{submitted};

    my $i = $self->mk_input( $w, { type => 'reset', value => $value } );

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
