package Catalyst::Model::DBI::SQL::Library;

use strict;
use base qw( Catalyst::Model::DBI );
use NEXT;
use SQL::Library;
use File::Spec;

our $VERSION = '0.13';

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
		dsn           => 'dbi:Pg:dbname=myapp',
		password      => '',
		user          => 'postgres',
		options       => { AutoCommit => 1 },
		sqldir        => 'root/sql' #optional, will default to $c->path_to ( 'root/sql' )
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
via sql accessor. Please refer to C<SQL::Library> for more information.

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
	eval { $self->sql ( SQL::Library->new ( { lib => $source } ) ); };
	if ($@) {
		$self->{log}->debug( qq{Couldn't create SQL::Library instance for: "$source" Error: "$@"} ) 
			if $self->{debug}; 
	} else { 
		$self->{log}->debug ( qq{SQL::Library instance created for: "$source"} ) 
			if $self->{debug}; 
	}
	return $self->sql;
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
