#!/usr/bin/perl

use strict;
use YAML qw(Dump);

my %config = (
	name => 'ServerDB',
	dsn => 'dbi:SQLite2:__HOME__/ServerDB.db',
	plucene_dir => '/plucene',
	authentication => {
		user_class => 'ServerDB::M::CDBI::User',
		user_field => 'username',
		password_field => 'password',
		password_hash => 'sha',
		role_class => 'ServerDB::M::CDBI::Role',
		user_role_class => 'ServerDB::M::CDBI::UserRole',
		user_role_user_field => 'user',
	},
);

print Dump( \%config );
