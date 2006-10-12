#!/usr/bin/perl
#
# Index the ServerDB database for searching

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use ServerDB::Search::Plucene;
use ServerDB::Script::CDBI;
use Data::Dumper;

# index, and optional search query to run
my ($index, $query) = (shift, shift);

my $p = ServerDB::Search::Plucene->open($index) or die "Unable to open index $index";

if ($query) {
	print "Search results for $query:\n";
	my @results = $p->search($query);
	print Dumper(\@results);
} else {
	foreach my $server (ServerDB::M::CDBI::Server->retrieve_all) {
		my $key = $server->name;
		my @data = ();
		foreach my $field ($server->columns) {
			push @data, $server->$field;
			# split out hostname fields and email address parts for the index
			push @data, split(/\./, $server->$field) if ($field eq "name");
			push @data, split(/\@/, $server->$field) if ($field eq "owner");			
		}
		# add applications
		foreach my $app ($server->applications) {
			push @data, $app->type;
			push @data, $app->description;
		}
		$p->delete_document($key) if ($p->indexed($key));
		$p->index_document( $key => join " ", @data );
		print "Indexed data for server: $key\n";
	}
	
	$p->optimize;
}



