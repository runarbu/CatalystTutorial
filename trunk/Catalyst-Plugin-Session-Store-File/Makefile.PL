use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Catalyst::Plugin::Session::Store::File',
    VERSION_FROM =>
      'lib/Catalyst/Plugin/Session/Store/File.pm',    # finds $VERSION
    PREREQ_PM => {
        'Class::Data::Inheritable'  => '0.04',
        'Class::Accessor::Fast'     => '0.22',
        'Catalyst::Plugin::Session' => '0.01',
        'Cache::Cache'              => '1.02',
    },    # e.g., Module::Name => 1.1
    (
        $] >= 5.005
        ?    ## Add these new keywords supported since 5.005
          (
            ABSTRACT_FROM => 'lib/Catalyst/Plugin/Session/Store/File.pm'
            ,    # retrieve abstract from module
            AUTHOR => 'Sascha Kiefer <esskar@cpan.org>'
          )
        : ()
    ),
);
