use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'Catalyst::Model::DBIC',
    AUTHOR    => 'Sebastian Riedel (sri@oook.de)',
    PREREQ_PM => {
        Catalyst            => '5.00',
        DBIx::Class         => 0,
        DBIx::Class::Loader => 0
    },
    VERSION_FROM => 'lib/Catalyst/Model/DBIC.pm'
);
