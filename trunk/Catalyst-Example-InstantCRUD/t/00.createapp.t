use strict;
use warnings;
use Test::More tests => 1;
use Path::Class;
use File::Path;
use File::Copy;

rmtree( ['t/tmp/My-App', 't/tmp/test.db'] );

my $testfile = file('t', 'tmp', 'test.db')->absolute;
my $origtestfile = file('t', 'var', 'test.db')->absolute;

copy $origtestfile, $testfile;

`cd t/tmp; perl -I../../lib ../../script/instantcrud.pl -name=My::App -dsn='dbi:SQLite:dbname=$testfile'`;

ok( -f 't/tmp/My-App/lib/DBSchema.pm', 'DBSchema creation');


