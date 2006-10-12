use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'Catalyst::Plugin::I18N',
    AUTHOR    => 'Sebastian Riedel (sri@oook.de)',
    PREREQ_PM => {
        'Catalyst'                  => '2.99',
        'Locale::Maketext::Simple'  => 0,
        'I18N::LangTags::Detect'    => 0,
        'Locale::Maketext::Lexicon' => 0,
    },
    VERSION_FROM => 'I18N.pm'
);
