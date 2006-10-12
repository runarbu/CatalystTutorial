package HTML::Widget::Constraint::Callback;

use warnings;
use strict;
use base 'HTML::Widget::Constraint';

__PACKAGE__->mk_accessors(qw/callback/);

*cb = \&callback;

=head1 NAME

HTML::Widget::Constraint::Callback - Callback Constraint

=head1 SYNOPSIS

    my $c = $widget->constraint( 'Callback', 'foo' )->callback(sub { 
        my $value=shift;
        return 1;
    });

=head1 DESCRIPTION

Callback Constraint.

=head1 METHODS

=head2 $self->cb( sub { $value=shift; } )

=head2 $self->callback( sub { $value=shift; } )

define the callback to be used for validation. cb is an alias
to callback.


=head2 $self->validate($value)

perform the actual validation.

=cut

sub validate {
    my ( $self, $value ) = @_;
    my $callback = $self->callback || sub { 1 };
    return $callback->($value);
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

Marcus Ramberg, C<mramberg@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
