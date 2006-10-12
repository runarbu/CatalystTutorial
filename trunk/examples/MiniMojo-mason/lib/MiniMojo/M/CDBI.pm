package MiniMojo::M::CDBI;

use strict;
use base 'Catalyst::Model::CDBI';

__PACKAGE__->config(
    dsn           => 'dbi:SQLite:/Users/jason/sandbox/perl/catalyst/MiniMojo/db/minimojo.db',
    user          => '',
    password      => '',
    options       => {},
    relationships => 1
);

=head1 NAME

MiniMojo::M::CDBI - CDBI Model Component

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

