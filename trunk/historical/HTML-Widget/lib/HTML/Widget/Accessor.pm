package HTML::Widget::Accessor;

use warnings;
use strict;
use base 'Class::Accessor::Chained::Fast';

__PACKAGE__->mk_accessors(qw/attributes/);

*attrs = \&attributes;

=head1 NAME

HTML::Widget::Accessor - Accessor Class

=head1 SYNOPSIS

    use base 'HTML::Widget::Accessor';

=head1 DESCRIPTION

Accessor Class.

=head1 METHODS

=head2 $self->attributes(@attributes)

=head2 $self->mk_attr_accessors(@names)

=cut

sub mk_attr_accessors {
    my ( $self, @names ) = @_;
    my $class = ref $self || $self;
    for my $name (@names) {
        no strict 'refs';
        *{"$class\::$name"} = sub {
            return ( $_[0]->{attributes}->{$name} || $_[0] ) unless @_ > 1;
            my $self = shift;
            $self->{attributes}->{$name} = ( @_ == 1 ? $_[0] : [@_] );
            return $self;
          }
    }
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
