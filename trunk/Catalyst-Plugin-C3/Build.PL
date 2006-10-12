use strict;
use Module::Build;

my %arguments = (
    license            => 'perl',
    module_name        => 'Catalyst::Plugin::C3',
    requires           => {
        'NEXT'       => 0.60,
        'Class::C3'  => 0.12,
    },
    build_requires     => {
        'Test::More' => 0.32,
    },
    create_makefile_pl => 'passthrough',
    create_readme      => 1,
);

Module::Build->new(%arguments)->create_build_script;
