package HTML::Widget::Constraint;

use warnings;
use strict;
use base 'Class::Accessor::Chained::Fast';
use HTML::Widget::Error;

__PACKAGE__->mk_accessors(qw/message names not/);

*msg = \&message;

=head1 NAME

HTML::Widget::Constraint - Constraint Base Class

=head1 SYNOPSIS

    my $c = $widget->constraint( $type, @names );
    $c->message('Validation error.');
    $c->names(@names);
    $c->not(1);

=head1 DESCRIPTION

Constraint Base Class.

=head1 METHODS

=head2 $self->default_message

Default error message for failing constraints.

=cut

sub default_message { 'Invalid Input' }

=head2 $self->init($widget)

Called once when process() gets called for the first time.

=cut

sub init { }

=head2 $self->javascript($id)

Should return JavaScript for client side validation and the like.

=cut

sub javascript { }

=head2 $self->msg($message)

=head2 $self->message($message)

Contains the validation error message.

=head2 $self->mk_message

Returns a validation error message.

=cut

sub mk_message { return $_[0]->message || $_[0]->default_message }

=head2 $self->names(@names)

Contains names of params to test.

=head2 $self->not($not)

Negate constraint.

=head2 $self->prepare($widget)

Called every time process() gets called.

=cut

sub prepare { }

=head2 $self->process( $widget, $params, $uploads )

Validates params and returns a arrayref containing L<HTML::Widget::Error>
objects representing failed constraints.

=cut

sub process {
    my ( $self, $w, $params ) = @_;

    my $results = [];

    for my $name ( @{ $self->names } ) {
        my $values = $params->{$name};
        my @values = ref $values eq 'ARRAY' ? @$values : ($values);
        for my $value (@values) {
            my $result = $self->validate($value);
            push @$results,
              HTML::Widget::Error->new(
                { name => $name, message => $self->mk_message } )
              if $self->not ? $result : !$result;
        }
    }

    return $results;
}

=head2 $self->process_js($id)

Returns a hashref containing JavaScripts for client side validation and
the like.

=cut

sub process_js {
    my ( $self, $id ) = @_;
    my %js;
    for my $name ( @{ $self->names } ) {
        $js{$name} = $self->javascript("$id\_$name");
    }
    return \%js;
}

=head2 $self->validate($value)

Validates a value and returns 1 or 0.

=cut

sub validate { 1 }

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
