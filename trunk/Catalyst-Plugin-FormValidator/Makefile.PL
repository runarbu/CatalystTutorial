use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'Catalyst::Plugin::FormValidator',
    AUTHOR    => 'Sebastian Riedel (sri@oook.de)',
    PREREQ_PM => {
        Catalyst              => '2.99',
        'Data::FormValidator' => 0
    },
    VERSION_FROM => 'FormValidator.pm'
);
