use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'Catalyst::Plugin::Prototype',
    'VERSION_FROM' => 'lib/Catalyst/Plugin/Prototype.pm',
    'PREREQ_PM'    => {
        Class::Data::Inheritable => 0,
        Catalyst                 => 0,
        HTML::Prototype          => '1.30'
    }
);
