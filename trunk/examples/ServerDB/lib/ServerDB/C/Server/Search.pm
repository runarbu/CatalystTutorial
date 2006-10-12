package ServerDB::C::Server::Search;

use strict;
use base 'Catalyst::Base';
use ServerDB::Search::Plucene;

sub default : Private {
    my ( $self, $c ) = @_;
    $c->forward('form');
}

# setup common variables we need in all server classes
sub auto : Private {
	my ($self, $c) = @_;
	
	$c->stash->{nav} = "search";
	
	return 1;
}

# the search form
sub form : Local {
	my ($self, $c) = @_;
	
	$c->stash->{template} = "server/search/form.xhtml";
}

sub results : Local {
	my ($self, $c) = @_;
	
	$c->stash->{template} = "server/search/results.xhtml";
	
	my $q = $c->req->params->{q};
	unless ($q) {
		$c->forward('form');
	} else {
		my $p = ServerDB::Search::Plucene->open( ServerDB->config->{home} . ServerDB->config->{plucene_dir} );
		my @results = ();
		foreach my $key (sort $p->search($q)) {
			my $server = ServerDB::M::CDBI::Server->retrieve($key);
			push @results, $server;
		}
		if (scalar @results) {
			$c->stash->{servers} = \@results;
			$c->stash->{searchResultCount} = scalar @results;
		}
	}
}

1;

