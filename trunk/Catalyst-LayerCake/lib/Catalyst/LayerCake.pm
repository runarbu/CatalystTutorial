package Catalyst::LayerCake;

use Catalyst;
use warnings;
use strict;

sub import {
    my ( $class, @arguments ) = @_;

    # We have to limit $class to Catalyst to avoid pushing Catalyst upon every
    # callers @ISA.
    return unless $class eq 'Catalyst::LayerCake';

    my $caller = caller(0);

    unless ( $caller->isa('Catalyst::LayerCake') ) {
        no strict 'refs';
        push @{"$caller\::ISA"}, $class;
    }

    $caller->arguments( [@arguments] );
    $caller->setup_home;
}


sub setup {
    my $class=shift;
    return $class->NEXT::setup(@_, qw/DefaultEnd Static::Simple Session/);
}


=head1 NAME

Catalyst::LayerCake - The great new Catalyst::LayerCake!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    package MyApp;
    use Catalyst::LayerCake;

=head1 DESCRIPTION

Catalyst Layer Cake is an opinionated Catalyst distribution. It selects
modules and configures Catalyst to get you up and running quicker. It's
not for everybody, but if it's for you, we believe it will make your life
easier.

=head1 AUTHOR

Marcus Ramberg, C<< <marcus@thefeed.no> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-catalyst-layercake@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Catalyst-LayerCake>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 Marcus Ramberg, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Catalyst::LayerCake
