use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'XML::RAI::Aggregate',
    'VERSION_FROM' => 'Aggregate.pm',
    'PREREQ_PM'    => { LWP::Simple => 0,
                        XML::RAI => 0
                      }
);
