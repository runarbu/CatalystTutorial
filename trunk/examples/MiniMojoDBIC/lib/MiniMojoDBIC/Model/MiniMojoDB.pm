package MiniMojoDBIC::Model::MiniMojoDB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'MiniMojoDB',
    connect_info => [
        'dbi:SQLite:minimojo.db',
        '',
        '',
        { AutoCommit => 1},
    ],
);

=head1 NAME

MiniMojoDBIC::Model::MiniMojoDB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<MiniMojoDBIC>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema
L<MiniMojoDB>

=head1 AUTHOR

Clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
