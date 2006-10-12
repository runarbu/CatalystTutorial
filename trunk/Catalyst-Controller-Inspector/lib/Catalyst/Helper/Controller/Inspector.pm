package Catalyst::Helper::Controller::Inspector;

use strict;
use warnings;

our $VERSION = '0.01';

sub mk_compclass {
    my( $self, $helper ) = @_;

    $helper->render_file( 'controllerclass', $helper->{ file } );

    return 1;
}

sub mk_comptest {
    my( $self, $helper ) = @_;

    $helper->render_file( 'controllertest', $helper->{ test } );
}

__DATA__

__controllerclass__
package [% class %];

use strict;
use base qw( Catalyst::Controller::Inspector );

=head1 NAME

[% class %] - Catalyst Inspector component

=head1 SYNOPSIS

See L<[% app %]>.

=head1 DESCRIPTION

Provides introspection on your Catalyst app.

=head1 AUTHOR

[% author %]

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
__controllertest__
use Test::More tests => 2;
use_ok(Catalyst::Test, '[% app %]');
use_ok('[% class %]');
