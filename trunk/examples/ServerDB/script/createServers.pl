#!/usr/bin/perl
# insert some server data taken from the public NTP time servers

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use ServerDB::Script::CDBI;
use Text::CSV_XS;
 
$| = 1;

# CSV file format:
# Country,State,Name,IP,Owner
my $csv = Text::CSV_XS->new;
open CSV, "<$FindBin::Bin/../script/NTPServers.csv" or die "Unable to open script/NTPServers.csv";
while (<CSV>) {
	if ($csv->parse($_)) {
		my @fields = $csv->fields;
		my $server = ServerDB::M::CDBI::Server->find_or_create( {
			name => $fields[2],
			ip_address => $fields[3],
			country => $fields[0],
			state => $fields[1],
			owner => $fields[4],
		} );
		print "Inserted server " . $fields[2] . "\n";
	}
}
close CSV;
