package HTML::Widget::Filter::Callback;

use warnings;
use strict;
use base 'HTML::Widget::Filter';

__PACKAGE__->mk_accessors(qw/callback/);

*cb = \&callback;

=head1 NAME

HTML::Widget::Filter::Callback - Lower Case Filter

=head1 SYNOPSIS

    my $f = $widget->filter( 'Callback', 'foo' )->callback(sub {
        my $value=shift;
        $value =~ s/before/after/g;
        return $value;
    });

=head1 DESCRIPTION

Callback Filter.

=head1 METHODS

=head1 $self->callback( sub { $value=shift;} );

define the callback to e used for filter. cb is an alias
to callback.

=head2 $self->filter($value)

=cut

sub filter {
    my ( $self, $value ) = @_;
    my $callback = $self->callback || sub { $_[0] };
    return $callback->($value);
}

=head1 AUTHOR

Lyo Kato, C<lyo.kato@gmail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
