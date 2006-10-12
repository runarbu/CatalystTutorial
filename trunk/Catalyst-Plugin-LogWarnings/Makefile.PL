use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Catalyst::Plugin::LogWarnings',
    AUTHOR              => 'Jonathan Rockway <jrockway@cpan.org>',
    VERSION_FROM        => 'lib/Catalyst/Plugin/LogWarnings.pm',
    ABSTRACT_FROM       => 'lib/Catalyst/Plugin/LogWarnings.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Catalyst::Runtime' => 5.7001,
	'Class::C3' => 0,
	'Catalyst::Plugin::C3' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Catalyst-Plugin-LogWarnings-*' },
);
