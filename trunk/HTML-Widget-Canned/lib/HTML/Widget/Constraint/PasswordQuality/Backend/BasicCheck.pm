#!/usr/bin/perl

package HTML::Widget::Constraint::PasswordQuality::Backend::BasicCheck;
use base qw/HTML::Widget::Constraint::PasswordQuality/;

use strict;
use warnings;

__PACKAGE__->mk_accessors(qw/_checker/);

sub new {
    require Data::Password::BasicCheck;
    my $self = shift->SUPER::new( @_ );

    $self->_checker( Data::Password::BasicCheck->new( $self->min, $self->max, 0.5 ) );

    $self->message("Password is too weak");

    $self;
}

sub validate {
    my ( $self, $password ) = @_;
    !$self->_checker->check( $password );
}

__PACKAGE__;

__END__

=pod

=head1 NAME

HTML::Widget::Constraint::PasswordQuality::Backend::BasicCheck - 

=head1 SYNOPSIS

	use HTML::Widget::Constraint::PasswordQuality::Backend::BasicCheck;

=head1 DESCRIPTION

=cut


