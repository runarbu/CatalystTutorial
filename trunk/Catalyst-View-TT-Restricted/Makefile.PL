use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'Catalyst::View::TT::Restricted',
    AUTHOR    => 'Marcus Ramberg <mramberg@cpan.org>',
    PREREQ_PM => {
        Catalyst     => '5.10',
    },
    VERSION_FROM => 'lib/Catalyst/View/TT/Restricted.pm'
);
