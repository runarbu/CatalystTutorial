package ServerDB::C::Server::Apps;

use strict;
use base 'Catalyst::Base';
my $dbi = 'ServerDB::M::CDBI::Application';

sub default : Private {
	my ($self, $c) = @_;
	$c->forward('/server/list');
}

sub auto : Private {
	my ($self, $c) = @_;
	$c->stash->{servernav} = "apps";
	return 1;
}

sub apps : Path('/server/apps') {
	my ($self, $c, @name) = @_;
	
	$c->stash->{template} = "server/apps.xhtml";
}

# add an application
sub add : Local {
	my ($self, $c, @name) = @_;
	
	# make sure the user is an admin
	if ($c->roles('admin')) {
		if ($c->req->params->{type}) {
			$c->stash->{server}->add_to_applications( {
				type => $c->req->params->{type},
				description => $c->req->params->{description},
			} );
			
			# update search index
			ServerDB::Search::Plucene->updateIndex( ServerDB->config->{home} . ServerDB->config->{plucene_dir}, $c->stash->{server} );
		}
		
		$c->forward('apps', join "/", @name);
	}
}

# edit an application
sub edit : Local {
	my ($self, $c, $id) = @_;
	
	my $app = $dbi->retrieve($id);
	$c->stash->{app} = $app;
	
	if ($app) {
		$c->stash->{template} = "server/apps/edit.xhtml";
	}
}

# update the apps data
sub doEdit : Local {
	my ($self, $c, $id) = @_;
	
	# make sure the user is an admin
	if ($c->roles('admin')) {
		$c->stash->{app} = $dbi->retrieve( $id );
		
		my $serverName = $c->stash->{app}->server->name; 
		
		if ($c->req->params->{delete}) {
			# grab the server so we can update the index after the app has been deleted
			my $server = $c->stash->{app}->server;
			
			$c->stash->{app}->delete;
			
			# update the search index
			ServerDB::Search::Plucene->updateIndex( ServerDB->config->{home} . ServerDB->config->{plucene_dir}, $server );
		} else {
			# only accept the editable fields for entry into the database
			$c->form( optional => [ qw/type description/ ] );
			$c->stash->{app}->update_from_form( $c->form );
			
			# update the search index
			ServerDB::Search::Plucene->updateIndex( ServerDB->config->{home} . ServerDB->config->{plucene_dir}, $c->stash->{app}->server );
		}
		
		$c->res->redirect('/server/apps/' . $serverName );
	}
}

1;
