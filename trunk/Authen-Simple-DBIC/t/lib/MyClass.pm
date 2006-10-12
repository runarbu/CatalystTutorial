package MyClass;

use strict;
use warnings;
use base qw[DBIx::Class];

__PACKAGE__->load_components( 'DB', 'Core' );
__PACKAGE__->table('users');
__PACKAGE__->add_columns( 'username', 'password' );
__PACKAGE__->set_primary_key('username');
__PACKAGE__->connection('dbi:SQLite:dbname=t/var/database.db');

1;
