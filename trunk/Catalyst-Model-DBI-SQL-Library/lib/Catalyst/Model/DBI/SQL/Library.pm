package Catalyst::Model::DBI::SQL::Library;

use strict;
use base qw( Catalyst::Model::DBI );
use NEXT;
use SQL::Library;
use File::Spec;

our $VERSION = '0.14';

__PACKAGE__->mk_accessors('sql');

=head1 NAME

Catalyst::Model::DBI::SQL::Library - SQL::Library DBI Model Class

=head1 SYNOPSIS

	# use the helper
	create model DBI::SQL::Library DBI::SQL::Library dsn user password
	
	# lib/MyApp/Model/DBI/SQL/Library.pm
	package MyApp::Model::DBI::SQL::Library;
	
	use base 'Catalyst::Model::DBI::SQL::Library';
	
	__PACKAGE__->config(
		dsn			=> 'dbi:Pg:dbname=myapp',
		password		=> '',
		user			=> 'postgres',
		options			=> { AutoCommit => 1 },
		sqldir			=> 'root/sql' #optional, will default to $c->path_to ( 'root/sql' ),
		sqlcache		=> 1 #can only be used when queries are loaded from file i.e. via scalar passed to load
		sqlcache_use_mtime	=> 1 #will use modification time of the file to determine when to refresh the cache
	);

	1;
	
	my $model = $c->model( 'DBI::SQL::Library' );
	my $sql = $model->load ( 'something.sql' ) ;
	
	#or my $sql = $model->load ( [ <FH> ] );
	#or my $sql = $model->load ( [ $sql_query1, $sql_query2 ] ) )
	
	my $query = $sql->retr ( 'some_sql_query' );
	
	#or my $query = $model->sql->retr ( 'some_sql_query );	
	
	$model->dbh->do ( $query );
	
	#do something else with $sql ...
	
=head1 DESCRIPTION

This is the C<SQL::Library> model class. It provides access to C<SQL::Library>
via sql accessor. Additional caching options are provided for increased performance
via sqlcache and sqlcache_use_mtime, these options can only be used when sql strings are
stored within a file and loaded by using a scalar value passed to load. The load and parse
phase is then bypassed if cached version of the file is found. The use of these options can
result in more memory being used but faster access to query data when running under persistent
environment such as mod_perl or FastCGI. When sqlcache_use_mtime is in use, last modification
time of the file is being referenced upon every cache check. If the modification time has changed
query file is then re-loaded. This may slower the application a little bit, but should still be
much faster then re-creating the SQL::Library instance on every load. Please refer to the
C<SQL::Library> for more information.

=head1 METHODS

=over 4

=item new

Initializes database connection

=cut 

sub new {
	my ( $self, $c ) = @_;
	$self = $self->NEXT::new($c);
	$self->{sqldir} ||= $c->path_to ( 'root/sql' );
	$self->{log} = $c->log;
	$self->{debug} = $c->debug;
	return $self;
}

=item $self->load

Initializes C<SQL::Library> instance

=cut

sub load {
	my ( $self, $source ) = @_;
	$source = File::Spec->catfile ( $self->{sqldir}, $source ) unless ref $source eq 'ARRAY';
	if ( ref $source ne 'ARRAY' && $self->{sqlcache} && exists $self->{obj_cache}->{$source} ) {
		my $source_cached = $self->{obj_cache}->{$source};
		if ( $self->{sqlcache_use_mtime} && exists $source_cached->{mtime} ) {
			my $mtime_current = $self->_extract_mtime ( $source );
			if ( $mtime_current != $source_cached->{mtime} ) {
				$self->{log}->debug (
					qq{Mtime changed for cached SQL::Library instance with path: "$source", reloading}
				)  if $self->{debug};
				$self->_load_instance ( $source );
			} else {
				$self->sql ( $source_cached->{sql} );
				$self->{log}->debug (
					qq{Cached SQL::Library instance with path: "$source" and mtime: "$mtime_current" found}
				)  if $self->{debug};
			}
  		} else {
			$self->sql ( $source_cached->{sql} );
			$self->{log}->debug ( qq{Cached SQL::Library instance with path: "$source" found} )
				if $self->{debug};
		}
	} else {
		$self->_load_instance ( $source );
	}
	return $self->sql;
}

sub _load_instance {
	my ( $self, $source ) = @_;
	eval { $self->sql ( SQL::Library->new ( { lib => $source } ) ); };
	if ($@) {
		$self->{log}->debug( qq{Couldn't create SQL::Library instance with path: "$source" Error: "$@"} )
			if $self->{debug};
	} else { 
		$self->{log}->debug ( qq{SQL::Library instance created with path: "$source"} )
			if $self->{debug};
		if ( $self->{sqlcache} && ref $source ne 'ARRAY' ) {
			if ( $self->{sqlcache_use_mtime} ) {
				my $mtime = $self->_extract_mtime ( $source );
				$self->{obj_cache}->{$source} = {
					sql => $self->sql,
					mtime => $mtime
				}; 
				$self->{log}->debug ( qq{Caching SQL::Library instance with path: "$source" and mtime: "$mtime"} )
					if $self->{debug};
			} else {
				$self->{obj_cache}->{$source} = { sql => $self->sql };
				$self->{log}->debug ( qq{Caching SQL::Library instance with path: "$source"} )
					if $self->{debug};
			}
		}
	}
}

sub _extract_mtime {
	my ( $self, $source ) = @_;
	my $mtime;
	if (-r $source) {
		$mtime = return (stat(_))[9];
	} else {
		$self->{log}->debug( 
			qq{Couldn't extract modification time for path: "$source"}
		) if $self->{debug};
	}
	return $mtime;
}

=item $self->dbh

Returns the current database handle.

=item $self->sql

Returns the current C<SQL::Library> instance

=back

=head1 SEE ALSO

L<Catalyst>, L<DBI>

=head1 AUTHOR

Alex Pavlovic, C<alex.pavlovic@taskforce-1.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it 
under the same terms as Perl itself.

=cut

1;
