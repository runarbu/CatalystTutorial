package MiniMojoDB::Page;
use base qw /DBIx::Class/;
__PACKAGE__->load_components (qw/PK::Auto Core/);
__PACKAGE__->table('page');
__PACKAGE__->add_columns(qw/id title body/);
__PACKAGE__->set_primary_key(qw/id/);
=head1 NAME

MiniMojo - A very nice application

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice ORM Class

=head1 AUTHOR

Clever guy

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
