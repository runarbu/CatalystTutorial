#!/usr/bin/perl


package HTML::Widget::Constraint::PasswordQuality::Backend::Check;
use base qw/HTML::Widget::Constraint::PasswordQuality/;

use strict;
use warnings;

sub new {
    require Data::Password::Check;
    shift->SUPER::new( @_ );
}

sub validate {
    my ( $self, $password ) = @_;

    my $check = Data::Password::Check->check({ password => $password, min_length => $self->min });

    if ( $check->has_errors ) {
        $self->message( join(", ", @{ $check->error_list } ) );
        return;
    } else {
        return 1;
    }
}

__PACKAGE__;

__END__

=pod

=head1 NAME

HTML::Widget::Constraint::PasswordQuality::Backend::Check - 

=head1 SYNOPSIS

	use HTML::Widget::Constraint::PasswordQuality::Backend::Check;

=head1 DESCRIPTION

=cut


