package HTML::Widget::Element::Button;

use warnings;
use strict;
use base 'HTML::Widget::Element';
use NEXT;

__PACKAGE__->mk_accessors(qw/value content type retain_default/);

# alias
*label = \&value;

=head1 NAME

HTML::Widget::Element::Button - Button Element

=head1 SYNOPSIS

    $e = $widget->element( 'Button', 'foo' );
    $e->value('bar');

=head1 DESCRIPTION

Button Element.

=head1 METHODS

=head2 value

=head2 label

The value of this Button element. Is also used by the browser as the 
button label.

L</label> is an alias for L</value>.

=head2 content

If set, the element will use a C<button> tag rather than an C<input> 
tag.

The value of C<content> will be used between the C<button> tags, unescaped.
This means that any html markup may be used to display the button.

=head2 type

Only used if L</content> is set.

Defaults to C<button>. Also valid is C<submit> and C<reset>.

=head2 retain_default

If true, overrides the default behaviour, so that after a field is missing 
from the form submission, the xml output will contain the default value, 
rather than be empty.

=head2 render

=head2 containerize

=cut

sub containerize {
    my ( $self, $w, $value, $errors, $args ) = @_;

    $value = ref $value eq 'ARRAY' ? shift @$value : $value;

    $value = $self->value
        if ( not defined $value )
        and $self->retain_default || not $args->{submitted};

    my $i;
    if ( defined $self->content && length $self->content ) {
        my $type = $self->type() if defined $self->type;
        $type = 'button' if not defined $type;

        $i = $self->mk_tag( $w, 'button', { type => $type, value => $value } );

        $i->push_content(
            HTML::Element->new( '~literal', text => $self->content ) );
    }
    else {
        $i = $self->mk_input( $w, { type => 'button', value => $value } );
    }

    return $self->container( { element => $i } );
}

=head1 SEE ALSO

L<HTML::Widget::Element>

=head1 AUTHOR

Marcus Ramberg, C<mramberg@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
