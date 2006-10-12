use strict;
use Test::More;
use Class::DBI::Sweet;
Class::DBI::Sweet->default_search_attributes({ use_resultset_cache => 1 });
Class::DBI::Sweet->cache(Cache::MemoryCache->new(
    { namespace => "SweetTest", default_expires_in => 60 } ) ); 

#----------------------------------------------------------------------
# Test database failures
#----------------------------------------------------------------------

BEGIN {
	eval "use Cache::MemoryCache";
	plan skip_all => "needs Cache::Cache for testing" if $@;
	eval "use DBD::SQLite";
	plan $@ ? (skip_all => 'needs DBD::SQLite for testing') : (tests => 7);
}

use lib 't/cdbi-t/testlib';
use Film;

Film->create_test_film;

{
	my $btaste = Film->retrieve('Bad Taste');
	isa_ok $btaste, 'Film', "We have Bad Taste";
	{
		no warnings 'redefine';
		local *DBIx::ContextualFetch::st::execute = sub { die "Database died" };
		eval { $btaste->delete };
		::like $@, qr/Database died/s, "We failed";
	}
	my $still = Film->retrieve('Bad Taste');
	isa_ok $btaste, 'Film', "We still have Bad Taste";
}

{
	my $btaste = Film->retrieve('Bad Taste');
	isa_ok $btaste, 'Film', "We have Bad Taste";
	$btaste->numexplodingsheep(10);
	{
		no warnings 'redefine';
		local *DBIx::ContextualFetch::st::execute = sub { die "Database died" };
		eval { $btaste->update };
		::like $@, qr/update.*Database died/s, "We failed";
	}
	$btaste->discard_changes;
	my $still = Film->retrieve('Bad Taste');
	isa_ok $btaste, 'Film', "We still have Bad Taste";
	is $btaste->numexplodingsheep, 1, "with 1 sheep";
}

if (0) {
	my $sheep = Film->maximum_value_of('numexplodingsheep');
	is $sheep, 1, "1 exploding sheep";
	{
		local *DBIx::ContextualFetch::st::execute = sub { die "Database died" };
		my $sheep = eval { Film->maximum_value_of('numexplodingsheep') };
		::like $@, qr/select.*Database died/s,
			"Handle database death in single value select";
	}
}

