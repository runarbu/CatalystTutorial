use ExtUtils::MakeMaker;

WriteMakefile(
	NAME => 		'Catalyst::Model::DBI::SQL::Library',
	AUTHOR => 		'Alex Pavlovic (alex.pavlovic@taskforce-1.com)',
	PREREQ_PM => {
		Catalyst => 	'5.00',
		DBI => 		0,
		SQL::Library =>	0,
	},
	VERSION_FROM => 	'lib/Catalyst/Model/DBI/SQL/Library.pm'
);
