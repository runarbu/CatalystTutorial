package ServerDB::M::CDBI;

use strict;
use base 'Catalyst::Model::CDBI';

my $dsn = ServerDB->config->{dsn};
my $home = ServerDB->config->{home};
$dsn =~ s/__HOME__/$home/;

__PACKAGE__->config(
	dsn => $dsn,
	additional_classes => [
		qw/Class::DBI::AbstractSearch Class::DBI::Plugin::AbstractCount
		Class::DBI::Plugin::Pager Class::DBI::FromForm/
	],
	relationships => 1,
);

1;
