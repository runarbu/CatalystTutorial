#!/usr/bin/perl

# suck down the list of NTP time servers from:
# http://ntp.isc.org/bin/view/Servers/StratumOneTimeServers

use strict;
use LWP::Simple;
use HTML::TableExtract;
use Text::CSV_XS;
use Net::DNS;

$| = 1;

my @pages = qw(
	http://ntp.isc.org/bin/view/Servers/StratumOneTimeServers
	http://ntp.isc.org/bin/view/Servers/StratumTwoTimeServers
);

my $csv = Text::CSV_XS->new;
my $output = "";

my $res = Net::DNS::Resolver->new;

foreach my $page (@pages) {
	my $table = get($page);
	if ($table) {
		my $te = new HTML::TableExtract( headers => [ ('ISO', 'HostName', 'ServerContact') ] );
		$te->parse( $table );
		foreach my $row ( $te->rows ) {
			my ($iso, $hostname, $contact) = @{$row};
			$iso =~ /\s*(\w{2})(\s+(\w{2}))?/;
			my ($country, $state) = ($1, $2);
			$state =~ s/\s//g;
			
			$hostname =~ s/\s//g;
			
			$contact =~ /(\w*\@(\w|\.)*)/;
			my $email = $1;
			
			my $ip = "";
			my $query = $res->search($hostname);
			if ($query) {
				foreach my $rr ($query->answer) {
					next unless $rr->type eq "A";
					$ip = $rr->address;
					last;
				}
			}
			
			$csv->combine( $country, $state, $hostname, $ip, $email );
			print $csv->string . "\n";
		}
	}
}

print $output;
