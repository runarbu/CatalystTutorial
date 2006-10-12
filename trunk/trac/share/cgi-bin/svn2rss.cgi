#!/usr/bin/perl

use strict;
use warnings;

use SVN::Ra;
use XML::RSS;
use CGI;
use Data::Dumper;


#config
my $resp_hdr = {
	-type => 'text/xml',
	-charset => 'utf-8',
};
my $repos = {
	base_url => 'http://dev.catalyst.perl.org/repos/',
	project_name => 'Catalyst',
};
my @fields = qw(paths revision author date message);
my @project_names = qw(Catalyst MojoMojo bast);

# init objects, extract & setup params
my $cgi = CGI->new();
my $project_name = $cgi->param('project') || 'Catalyst';
$repos->{project_name} = $project_name if grep { $_ eq $project_name } @project_names;
my $url = $repos->{base_url} . $repos->{project_name};
print STDERR "$url\n";
my $ra = SVN::Ra->new(url => $url) or die "Can't open Ra layer for $url";

my $start_rev = $cgi->param('start_rev') || 1;
my $end_rev = $cgi->param('end_rev') || -1;
my $last_revs = $cgi->param('last_revs');
$end_rev = $ra->get_latest_revnum () if $end_rev == -1;
if($last_revs) {
	$start_rev = $end_rev - $last_revs;
}

my $rss = XML::RSS->new(version => '2.0');
my @logs = ();

# RSS setup 
$rss->channel(
	title		=> "$repos->{project_name}: SVN Log",
	link		=> $url,
	description => "$repos->{project_name} SVN Log RSS Feed for purl",
	language	=> 'en',
	pubDate		=> scalar(gmtime()),
);

#print STDERR "Fetching rev $start_rev to $end_rev \n";

# go! 
print $cgi->header(%{$resp_hdr});

$ra->get_log( [''], $start_rev, $end_rev, 0, 1, 0, \&handle_log );

@logs = reverse @logs if $last_revs;

foreach my $log_item (@logs) {
	$rss->add_item(
		title => "[$log_item->{revision}] $log_item->{message} by $log_item->{author}",
	);
}

print $rss->as_string;

sub handle_log {

	my %log_entry = ();
	
	@log_entry{@fields} = @_;

	push @logs, \%log_entry;
}
