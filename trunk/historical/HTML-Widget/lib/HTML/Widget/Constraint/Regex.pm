package HTML::Widget::Constraint::Regex;

use warnings;
use strict;
use base 'HTML::Widget::Constraint';

__PACKAGE__->mk_accessors(qw/regex/);

=head1 NAME

HTML::Widget::Constraint::Regex - Regex Constraint

=head1 SYNOPSIS

    my $c = $widget->constraint( 'Regex', 'foo' );
    $c->regex(qr/^\w+$/);

=head1 DESCRIPTION

Regex Constraint.

=head1 METHODS

=head2 $self->regex($regex)

=head2 $self->validate($value)

=cut

sub validate {
    my ( $self, $value ) = @_;
    my $regex = $self->regex || qr/.*/;
    return 0 if ( defined $value && $value !~ $regex );
    return 1;
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
