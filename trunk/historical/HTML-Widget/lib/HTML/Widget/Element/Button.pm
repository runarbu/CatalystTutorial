package HTML::Widget::Element::Button;

use warnings;
use strict;
use base 'HTML::Widget::Element';
use NEXT;

__PACKAGE__->mk_accessors(qw/value content type/);

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

=head2 content

If set, the element will use a C<button> tag rather than an C<input> 
tag.

The value of C<content> will be used between the C<button> tags, unescaped.
This means that any html markup may be used to display the button.

=head2 type

Only used if L</content> is set.

Defaults to C<button>. Also valid is C<submit> and C<reset>.

=head2 $self->render( $widget, $value )

=cut

sub containerize {
    my ( $self, $w, $value ) = @_;

    $value = ref $value eq 'ARRAY' ? shift @$value : $value;

    $value ||= $self->value;
    my $i;
    if (defined $self->content && length $self->content) {
        my $type = $self->type() if defined $self->type;
        $type = 'button' if not defined $type;
        
        $i = $self->mk_tag( $w, 'button', { type => $type, value => $value } );
        
        $i->push_content(
            HTML::Element->new( '~literal', text => $self->content )
        );
    }
    else {
	   $i = $self->mk_input( $w, { type => 'button', value => $value } );
    }
    
    return $self->container( { element => $i } );
}

=head1 AUTHOR

Marcus Ramberg, C<mramberg@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
