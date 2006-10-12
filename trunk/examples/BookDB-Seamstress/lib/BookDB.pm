package BookDB;

use strict;
use Catalyst qw/-Debug FormValidator FillInForm Static::Simple/;

our $VERSION = '0.01';

BookDB->config( name => 'BookDB' );

BookDB->setup;


use lib '/ernest/dev/seamstress_bookdb';



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

use Data::Dumper;
#warn "PERCENT-INC: " . Dumper \%INC;

sub default : Private {
    my ( $self, $c ) = @_;
    $c->forward('/book/default');
}

sub end : Private {
  my ( $self, $c ) = @_;

  if (exists ($c->stash->{LOOM})) {
    $c->forward('BookDB::V::Seamstress');
  } else {
    warn 'forwarding to tt!';
    $c->forward('BookDB::V::TT');
  }

}

=back

=head1 AUTHOR

Marcus Ramberg

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
