package MiniMojo;

use strict;
use Catalyst qw/-Debug Prototype Textile/;

our $VERSION = '0.01';

MiniMojo->config( name => 'MiniMojo' );

MiniMojo->setup;

=head1 NAME

MiniMojo - Catalyst based application

=head1 SYNOPSIS

    script/minimojo_server.pl

=head1 DESCRIPTION

Catalyst based application.

=head1 METHODS

=over 4

=item default

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    
    $c->forward('/page/show');
}

sub end : Private {
    my ( $self, $c ) = @_;
    $c->forward('MiniMojo::V::Mason') unless $c->res->output;
}


=back

=head1 AUTHOR

Jason Gessner

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;
