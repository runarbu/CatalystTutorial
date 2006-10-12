use strict;
use Module::Build;

my $build = Module::Build->new(
    create_makefile_pl => 'passthrough',
    license            => 'perl',
    module_name        => 'Catalyst::Plugin::Component::Loader',
    requires           => { Catalyst => '5.20' },
    create_makefile_pl => 'passthrough',
    test_files   => [
        glob('t/*.t') 
    ],
    create_readme => 1,

);

$build->create_build_script;
