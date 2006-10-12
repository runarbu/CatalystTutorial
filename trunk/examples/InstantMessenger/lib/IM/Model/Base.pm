package IM::Model::Base;

use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components(qw(
    PK::Auto::SQLite
    Core
    DB
));

__PACKAGE__->connection(
    'dbi:SQLite:dbname='.IM->path_to('im.db'), '', ''
);

__PACKAGE__->storage->dbh->{unicode} = 1;

1;
