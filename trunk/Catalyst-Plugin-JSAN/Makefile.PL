use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'Catalyst::Plugin::JSAN',
    'VERSION_FROM' => 'lib/Catalyst/Plugin/JSAN.pm',
    'PREREQ_PM'    => {
        'JSAN'                  => 0,
        'JSAN::Parse::FileDeps' => 0
    }
);
