package SmokeServer::View::TT;

use strict;
use base 'Catalyst::View::TT::FunctionGenerator';

use Template::Stash::XS;

__PACKAGE__->config(
    TEMPLATE_EXTENSION => ".tt",
    INCLUDE_PATH => [ SmokeServer->path_to(qw/root templates/) ],
    STASH => Template::Stash::XS->new,
    COMPILE_DIR => SmokeServer->path_to(qw/tmp template_cache/)->stringify,
);

=head1 NAME

SmokeServer::View::TT - Catalyst TT View

=head1 SYNOPSIS

See L<SmokeServer>

=head1 DESCRIPTION

Catalyst TT View.

=head1 AUTHOR

יובל קוג'מן

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
