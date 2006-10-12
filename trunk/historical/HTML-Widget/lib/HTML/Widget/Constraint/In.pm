#!/usr/bin/perl

package HTML::Widget::Constraint::In;
use base 'HTML::Widget::Constraint';

use strict;
use warnings;

__PACKAGE__->mk_accessors(qw/_in _in_hash/);

sub new {
    my $self = shift->SUPER::new(@_);

    $self->_in_hash({});

    $self;
}

sub validate {
    my ( $self, $value ) = @_;
    exists $self->_in_hash->{$value};
}

sub in {
    my ( $self, @values ) = @_;

    if ( @values ) {
        $self->_in_hash( { map { $_ => undef } @values } );
        $self->_in( @values );
    };
    
    return $self->_in();
}

__PACKAGE__;

__END__

=pod

=head1 NAME

HTML::Widget::Constraint::In - Check that a value is one of a current set.

=head1 SYNOPSIS

    $widget->constraint( In => "foo" )->in(qw/possible values/);

=head1 DESCRIPTION

=head1 METHODS

=head2 in

A list of valid values for that element.

=cut


