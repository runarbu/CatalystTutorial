use strict;
use Module::Build;

my $build = Module::Build->new(
    create_makefile_pl => 'passthrough',
    license            => 'perl',
    module_name        => 'Catalyst::Plugin::Scheduler',
    requires           => { 
        'Catalyst'              => '5.61',
        'DateTime::Event::Cron' => 0,
        'Set::Scalar'           => 0,
        'Storable'              => 0,
        'YAML'                  => 0,
    },
    create_makefile_pl => 'passthrough',
    create_readme      => 1,
    test_files   => [
        glob('t/*.t') 
    ]
);
$build->create_build_script;
