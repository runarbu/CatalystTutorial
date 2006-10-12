package MiniMojo::V::Mason;

use strict;
use base 'Catalyst::View::Mason';

#__PACKAGE__->config->{DEBUG} = 'all';
__PACKAGE__->config->{comp_root} = '/Users/jason/sandbox/perl/catalyst/MiniMojo/root';
__PACKAGE__->config->{data_dir} = '/Users/jason/sandbox/perl/catalyst/MiniMojo/mason';

=head1 NAME

MiniMojo::V::Mason - Mason View Component

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
