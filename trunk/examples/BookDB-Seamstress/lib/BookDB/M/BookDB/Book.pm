package BookDB::M::BookDB::Book;

use strict;

__PACKAGE__->columns(list => qw/title author publisher year/);
__PACKAGE__->columns(view => qw/title genre author isbn publisher format year pages/);

=head1 NAME

BookDB::M::BookDB::Book - CDBI Table Class

=head1 SYNOPSIS

See L<BookDB>

=head1 DESCRIPTION

CDBI Table Class.

=head1 AUTHOR

Marcus Ramberg

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
