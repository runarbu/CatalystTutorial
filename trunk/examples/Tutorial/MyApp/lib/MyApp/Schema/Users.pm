package MyApp::Schema::Users;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("users");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "username",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "password",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "email_address",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "first_name",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "last_name",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "active",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04004 @ 2008-05-21 14:30:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MG0zfz0tQVnD0y5g28UHOg


# You can replace this text with custom content, and it will be preserved on regeneration

#
# Set relationships:
#

# has_many():
#   args:
#     1) Name of relationship, DBIC will create accessor with this name
#     2) Name of the model class referenced by this relationship
#     3) Column name in *foreign* table
__PACKAGE__->has_many(map_user_role => 'MyApp::Schema::UserRoles', 'user_id');

# many_to_many():
#   args:
#     1) Name of relationship, DBIC will create accessor with this name
#     2) Name of has_many() relationship this many_to_many() is shortcut for 
#     3) Name of belongs_to() relationship in model class of has_many() above 
#   You must already have the has_many() defined to use a many_to_many().
__PACKAGE__->many_to_many(roles => 'map_user_role', 'role');

1;
