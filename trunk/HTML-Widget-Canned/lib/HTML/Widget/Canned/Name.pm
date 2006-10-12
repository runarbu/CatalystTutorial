#!/usr/bin/perl

package HTML::Widget::Canned::Name;
use base qw/HTML::Widget/;

use strict;
use warnings;
no warnings "uninitialized";

my %titles = my @titles = qw/mr Mr. ms Ms. mrs Mrs. miss Miss dr Dr. prof Prof./;

sub new {
    my ( $class, $name, %opts ) = @_;
    my $self = $class->SUPER::new($name || "name");


    if ( $opts{title} eq "select" ) {
        $self->element( Select => "title" )->options(@titles)->label("Title");

        #this should be superseded by Select autoadding the constraint + ::In
        $self->constraint( Callback => "title" )->callback(sub { !$_[0] || exists $titles{$_[0]} });
    } elsif ( $opts{title} ) {
        $self->element( Textfield => "title" )->size(20)->label("Title");
        $self->constraint( Printable => "title" )->message("This field must contain only text");
    }


    $self->element( Textfield => "first_name" )->size(20)->label("First Name");

    if ( $opts{middle_name} ) {
        my $is_initial = $opts{middle_name} eq "initial";
        my $e = $self->element( Textfield => "middle_name" )->size( $is_initial ? 1 : 20 );

        if ( $is_initial ) {
            $self->constraint( Regex => "middle_name" )->regex(qr/^[[:alpha:]]$/)->message("This field must contain only letters");
            $self->constraint( Length => "middle_name" )->max(1)->min(0)->message("This field must contain only one letter");
        } else {
            $e->label("Middle Name");
            $self->constraint( Printable   => "middle_name" )->message("This field must contain only text");
        }
    }
    $self->element( Textfield => "last_name" )->size(20)->label("Last Name");

    $self->constraint( All => qw/first_name last_name/ )->message("Required field");
    $self->constraint( Printable  => qw/first_name last_name/ )->message("This field must contain only text");

    $self->filter("TrimEdges");

    $self;
}

__PACKAGE__;

__END__

=pod

=head1 NAME

HTML::Widget::Canned::Name - Precanned widget for name fields.

=head1 SYNOPSIS

	use HTML::Widget::Canned::Named;

    my $name_widget = HTML::WIdget::Canned::Named->new( "user_name" );

    $uber_widget->embed( $name_widget ); # or ->merge

=head1 DESCRIPTION

=head1 OPTIONS

=head2 title

=head2 middle_name

=cut


