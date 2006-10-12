package ServerDB::Script::CDBI;

# use CDBI modules from a non-Catalyst script

use strict;
use Class::DBI::Loader;

# Change this to the path to your database
my $dsn = "DBI:SQLite2:/home/andy/Catalyst-trunk/examples/ServerDB/ServerDB.db";

my $loader = Class::DBI::Loader->new( 
	dsn => $dsn,
	namespace => "ServerDB::M::CDBI",
	relationships => 1,
);

1;
