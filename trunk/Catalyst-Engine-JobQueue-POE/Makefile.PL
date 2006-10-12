use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Catalyst::Engine::JobQueue::POE',
    AUTHOR              => 'Kiki <kiki@bsdro.org>',
    VERSION_FROM        => 'lib/Catalyst/Engine/JobQueue/POE.pm',
    ABSTRACT_FROM       => 'lib/Catalyst/Engine/JobQueue/POE.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'            => 0,
        'version'               => 0,
        'Catalyst::Runtime'     => 5.7001,
        'POE::Component::Cron'  => 0.014,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Catalyst-Engine-JobQueue-POE-*' },
);
