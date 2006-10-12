use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'Catalyst::Model::Tangram',
    AUTHOR    => 'Sam Vilain',
    PREREQ_PM => {
        Catalyst => '5.22',
        Tangram  => 0,
    },
    VERSION_FROM => 'lib/Catalyst/Model/Tangram.pm'
);
