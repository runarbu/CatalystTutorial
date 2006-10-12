package ServerDB::C::Server;

use strict;
use base 'Catalyst::Base';
use Tie::IxHash;
use ServerDB::Search::Plucene;
my $dbi = 'ServerDB::M::CDBI::Server';

sub default : Private {
    my ( $self, $c ) = @_;
    $c->forward('list');
}

# setup common variables we need in all server classes
sub auto : Private {
	my ($self, $c) = @_;
	
	my $name = $c->req->{arguments};

	$c->stash->{nav} = "server";
	
	# note: join here is to support server names 
	# with forward slashes in them
	if (ref $name eq "ARRAY") {
		$c->stash->{server} = $dbi->retrieve( join "/", @{$name} );
	}
	
	# columns to display in the list, and their sanitized names
	my %columns = ();
	tie(%columns, 'Tie::IxHash',
		name => 'Server',
		ip_address => 'IP Address',
		country => 'Country',
		state => 'State',
		owner => 'Owner',
	);

	# there is some kind of tied hash bug in 5.8.4, 
	# so I'm passing these through seperately
	# also requires an ugly "index" hack in serverList.xhtml :(
	$c->stash->{columns} = [ values %columns ];
	$c->stash->{fields} = [ keys %columns ];
	
	return 1;
}

# Display the list of servers
sub list : Local {
	my ($self, $c) = @_;
	
#	$c->stash->{template} = "server/list.xhtml";
	$c->stash->{LOOM} = "root::server::list";

	# paginate the list
	my $pager = $dbi->pager;
	$pager->per_page( 20 );
	$pager->page( $c->req->params->{page} || 1 );
	$pager->where( { name => { '!=', undef } } );	# you're forced to set a where clause even if returning all data...
	
	my $order = $c->req->params->{order};
	if ($order) {
		$order .= " desc" if lc( $c->req->params->{o2} ) eq "desc";
		$pager->order_by( $order );
	}
	
	$c->stash->{servers} = [ $pager->search_where ];
	$c->stash->{pager} = $pager;
	
}

# view server details
sub view : Local {
  my ($self, $c, @name) = @_;
	
  #	$c->stash->{template} = "server/view.xhtml";
  $c->stash->{LOOM} = "root::server::view::" . 
      ($c->stash->{admin} ? 'admin' : 'user');
  $c->stash->{servernav} = "view";

  warn "LOOM:   " . $c->stash->{LOOM} ;

  # stupid tied hash bug...
  #$c->stash->{editableFields} = $self->_editableFields;
  #$c->stash->{roFields} = $self->_roFields;	

  $c->stash->{editableFields} = [ keys %{$self->_editableFields} ];
  $c->stash->{editableValues} = [ values %{$self->_editableFields} ];
  $c->stash->{roFields} = [ keys %{$self->_roFields} ];
  $c->stash->{roValues} = [ values %{$self->_roFields} ];
}

# update the editable server data
sub do_edit : Local {
	my ($self, $c, @name) = @_;
	
	# make sure the user is an admin
	if ($c->roles('admin')) {
		$c->stash->{server} = $dbi->retrieve( join "/", @name );
		
		# only accept the editable fields for entry into the database
		$c->form( optional => [ keys %{$self->_editableFields} ] );
		$c->stash->{server}->update_from_form( $c->form );
		
		# update the search index
		ServerDB::Search::Plucene->updateIndex( ServerDB->config->{home} . ServerDB->config->{plucene_dir}, $c->stash->{server} );		
		
		$c->forward('view', join "/", @name);
	}
}

# fields which may be edited
sub _editableFields {
	my $self = shift;
	my %editableFields = ();
	tie(%editableFields, 'Tie::IxHash',
		owner => "Owner",
		country => "Country",
		state => "State",
		support_status => "Support Status",
	);
	return \%editableFields;
}	

# read-only fields
sub _roFields {
	my $self = shift;
	my %roFields = ();
	tie (%roFields, 'Tie::IxHash',
		name => "Server Name",
		ip_address => "IP Address",
	);
	return \%roFields;
}

# all fields, used for csv output
sub _allFields {
	my $self = shift;
	my %allFields = ();
	tie (%allFields, 'Tie::IxHash',	
		name => "Server Name",
		ip_address => "IP Address",
		country => "Country",
		state => "State",
		owner => "Owner",
		support_status => "Support Status",
	);
	return \%allFields;
}

1;
