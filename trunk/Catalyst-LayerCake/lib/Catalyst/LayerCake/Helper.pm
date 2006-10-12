package Catalyst::LayerCake::Helper;

use base 'Catalyst::Helper';
use NEXT;

sub mk_app {
    my $self=shift;
    $self->NEXT::mk_app(@_);
}

sub _mk_appclass {
    my $self = shift;
    my $mod  = $self->{mod};
    $self->render_file( 'appclass', "$mod.pm" );
}

1;
__DATA__

__appclass__
package [% name %];

use strict;
use warnings;

use Catalyst::LayerCake;

our $VERSION = '0.01';

#
# Configure the application
#
__PACKAGE__->config( name => '[% name %]' );

#
# Start the application
#        -Debug : activates the debug mode for very useful log messages
#
__PACKAGE__->setup( qw/-Debug/ );

=head1 NAME

[% name %] - Catalyst based application

=head1 SYNOPSIS

    script/[% appprefix %]_server.pl

=head1 DESCRIPTION

Catalyst based application.

=head1 METHODS

=over 4

=item default

=cut

#
# Output a friendly welcome message
#
sub default : Private {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body( $c->welcome_message );
}

=back

=head1 AUTHOR

[% author %]

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
