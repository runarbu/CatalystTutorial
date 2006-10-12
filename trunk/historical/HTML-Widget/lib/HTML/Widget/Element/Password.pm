package HTML::Widget::Element::Password;

use warnings;
use strict;
use base 'HTML::Widget::Element';

__PACKAGE__->mk_accessors(qw/comment fill label value/);
__PACKAGE__->mk_attr_accessors(qw/size/);

=head1 NAME

HTML::Widget::Element::Password - Password Element

=head1 SYNOPSIS

    my $e = $widget->element( 'Password', 'foo' );
    $e->comment('(Required)');
    $e->fill(1);
    $e->label('Foo');
    $e->size(23);
    $e->value('bar');

=head1 DESCRIPTION

Password Element.

=head1 METHODS

=head2 $self->containerize( $widget, $value, $errors )

=cut

sub containerize {
    my ( $self, $w, $value, $errors ) = @_;

    $value = ref $value eq 'ARRAY' ? shift @$value : $value;

    $value = undef unless $self->fill;
    $value ||= $self->value;

    my $l = $self->mk_label( $w, $self->label, $self->comment, $errors );
    my $i =
      $self->mk_input( $w, { type => 'password', value => $value }, $errors );
    my $e = $self->mk_error( $w, $errors );

    return $self->container( { element => $i, error => $e, label => $l } );
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
