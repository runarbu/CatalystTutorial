use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'Catalyst::Plugin::FillInForm',
    AUTHOR    => 'Sebastian Riedel (sri@oook.de)',
    PREREQ_PM => {
        Catalyst         => '2.99',
        HTML::FillInForm => 0
    },
    VERSION_FROM => 'FillInForm.pm'
);
