package Sharkpool::M::CDBI;

use strict;
use base qw/CatalystX::Blog::Model::CDBI/;

CatalystX::Blog::Model::CDBI->connection(
    Sharkpool->config->{dsn},
    Sharkpool->config->{user},
    Sharkpool->config->{password}
);

=head1 NAME

Sharkpool::M::CDBI - CDBI Model Component

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

