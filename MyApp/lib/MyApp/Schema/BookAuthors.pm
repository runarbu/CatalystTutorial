package MyApp::Schema::BookAuthors;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("book_authors");
__PACKAGE__->add_columns(
  "book_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "author_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("book_id", "author_id");


# Created by DBIx::Class::Schema::Loader v0.04004 @ 2008-05-21 14:30:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/aRHB2aLI/Dv25J3a4Sj2w


# You can replace this text with custom content, and it will be preserved on regeneration

#
# Set relationships:
#

# belongs_to():
#   args:
#     1) Name of relationship, DBIC will create accessor with this name
#     2) Name of the model class referenced by this relationship
#     3) Column name in *this* table
__PACKAGE__->belongs_to(book => 'MyApp::Schema::Books', 'book_id');

# belongs_to():
#   args:
#     1) Name of relationship, DBIC will create accessor with this name
#     2) Name of the model class referenced by this relationship
#     3) Column name in *this* table
__PACKAGE__->belongs_to(author => 'MyApp::Schema::Authors', 'author_id');

1;
