use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Catalyst::LayerCake',
    AUTHOR              => 'Marcus Ramberg <marcus@thefeed.no>',
    VERSION_FROM        => 'lib/Catalyst/LayerCake.pm',
    INST_SCRIPT		=> 'script',
    ABSTRACT_FROM       => 'lib/Catalyst/LayerCake.pm',
    PL_FILES            => {},
    PREREQ_PM => {
	'Catalyst'   => 5.50,
	'Catalyst::Plugin::DefaultEnd' => 0.03,
	'Catalyst::View::TT' => 0.14,
	'Catalyst::Model::DBIC' => 0.10,
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Catalyst-LayerCake-*' },
);
