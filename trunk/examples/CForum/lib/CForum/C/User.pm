package CForum::C::User;

use strict;
use base 'Catalyst::Base';


sub default : Private {
    my ( $self, $c ) = @_;
    $c->res->output('Congratulations, CForum::C::User is on Catalyst!');
}


=head1 NAME

CForum::C::User - A Component

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice component.

=head1 AUTHOR

Clever guy

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;

