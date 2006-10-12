package ServerDB::C::Report;

use strict;
use base 'Catalyst::Base';
use Text::CSV_XS;

sub default : Private {
    my ( $self, $c ) = @_;
    $c->forward('list');
}

sub list : Local {
	my ($self, $c) = @_;
	
	$c->stash->{template} = "report/list.xhtml";
	$c->stash->{nav} = "report";
	
	# available reports
	$c->stash->{reports} = {
		'fullcsv' => 'Download complete server database as CSV file',
	};	
}

sub fullcsv : Local {
	my ($self, $c) = @_;
	
	my $csv = Text::CSV_XS->new( { always_quote => 1 } );
	my $output = "";
	my $fields = ServerDB::C::Server->_allFields;
	$csv->combine(values %{$fields});
	$output .= $csv->string . "\n";
	
	foreach my $server (ServerDB::M::CDBI::Server->retrieve_all) {
		my @rowData = ();
		foreach my $field (keys %{$fields}) {
			push @rowData, $server->$field;
		}
		$csv->combine(@rowData);
		$output .= $csv->string . "\n";
	}
	
	$c->res->headers->header( 'Content-Type', 'text/csv' );
	$c->res->headers->header( 'Content-Disposition', 'filename=ServerDB_servers.csv' );
	$c->res->output( $output );
}

1;
