package HTML::Widget::Constraint::Range;

use warnings;
use strict;
use base 'HTML::Widget::Constraint';

__PACKAGE__->mk_accessors(qw/minimum maximum/);

*min = \&minimum;
*max = \&maximum;

=head1 NAME

HTML::Widget::Constraint::Range - Range Constraint

=head1 SYNOPSIS

    my $c = $widget->constraint( 'Range', 'foo' );
    $c->min(23);
    $c->max(30);

=head1 DESCRIPTION

Range Constraint.

=head1 METHODS

=head2 $self->maximum($max)

=head2 $self->minimum($min)

=head2 $self->validate($value)

=cut

sub validate {
    my ( $self, $value ) = @_;
    my $minimum = $self->minimum;
    my $maximum = $self->maximum;
    my $failed  = 0;
    if ($minimum) {
        $failed++ unless ( $value >= $minimum );
    }
    if ($maximum) {
        $failed++ unless ( $value <= $maximum );
    }
    return !$failed;
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
