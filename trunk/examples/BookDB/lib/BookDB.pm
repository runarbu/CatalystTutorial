package BookDB;

use strict;
use Catalyst qw/-Debug FormValidator FillInForm DefaultEnd Static::Simple/;

our $VERSION = '0.01';

BookDB->config( name => 'BookDB' );

BookDB->setup;

=head1 NAME

BookDB - Catalyst based application

=head1 SYNOPSIS

    script/bookdb_server.pl

=head1 DESCRIPTION

Catalyst based application.

=head1 METHODS

=over 4

=item default

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->forward('/book/default');
}


=back

=head1 AUTHOR

Marcus Ramberg

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
