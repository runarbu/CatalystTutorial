#!/usr/bin/perl

package HTML::Widget::Canned::Password;
use base qw/HTML::Widget/;

use strict;
use warnings;
no warnings 'uninitialized';

sub new {
    my ( $class, $name ) = ( shift, shift );
    my $self = $class->SUPER::new($name || "password");

    my %opts = (
        min_length => 4,
        required => 1,
        @_,
    );

    use Data::Dumper;
    warn Dumper( \%opts );
    
    $self->element( Password => "password" )->label("Password")->size(20);
    $self->element( Password => "password_retype" )->label("Retype Password")->size(20);

    if ( $opts{required} ) {
        $self->constraint( All => qw/password/ )->message("You must choose a password.");
        $self->constraint( All => qw/password_retype/ )->message("You must retype the password.");
    } else {
        $self->constraint( AllOrNone => qw/password password_retype/ )->message("The password must be confirmed.");
    }
    
    $self->constraint( Equal => qw/password password_retype/ )->message("The passwords don't match.");
    
    my $length = $self->constraint( Length => "password" )->message("The password is too short.");
    $length->min( $opts{required} ? $opts{min_length} : 0 );
    $length->max( $opts{max_length} ) if $opts{max_length};

    if ( my $backend = $opts{quality} ){
        $backend = "Check" if $backend eq "1";
        my $passcheck = $self->constraint( "PasswordQuality::Backend::$backend" => "password" );
        $passcheck->min( $opts{required} ? $opts{min_length} : 0);
        $passcheck->max( $opts{max_length} ) if $opts{max_length};
    } 

    $self;
}

__PACKAGE__;

__END__

=pod

=head1 NAME

HTML::Widget::Canned::Password - 

=head1 SYNOPSIS

	use HTML::Widget::Canned::Password;

=head1 DESCRIPTION

=cut


