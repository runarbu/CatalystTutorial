use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'CForum',
    VERSION_FROM => 'lib/CForum.pm',
    PREREQ_PM    => { Catalyst => 5 },
    PREREQ_PM    => {
        Class::DBI::Plugin::CountSearch => 0,
    },
    test         => { TESTS => join ' ', ( glob('t/*.t'), glob('t/*/*.t') ) }
);
