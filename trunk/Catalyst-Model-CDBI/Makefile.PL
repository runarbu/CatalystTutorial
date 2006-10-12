use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'Catalyst::Model::CDBI',
    AUTHOR    => 'Sebastian Riedel (sri@oook.de)',
    PREREQ_PM => {
        Catalyst           => '4.00',
        Class::DBI         => 0,
        Class::DBI::Loader => 0.20
    },
    VERSION_FROM => 'lib/Catalyst/Model/CDBI.pm'
);
