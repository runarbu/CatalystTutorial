package MiniMojoDB;
use base qw/DBIx::Class::Schema/;
__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->load_classes(qw/Page/);

=head1 NAME

MiniMojoDB - A very nice application datastore

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice application.

=head1 AUTHOR

Clever guy

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut


1;
