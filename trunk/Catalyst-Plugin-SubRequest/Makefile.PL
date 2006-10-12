use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'Catalyst::Plugin::SubRequest',
    AUTHOR    => 'Marcus Ramberg <marcus@thefeed.no>',
    PREREQ_PM => {
        Catalyst     => '2.99',
        File::Slurp  => '0',
    },
    VERSION_FROM => 'SubRequest.pm'
);
