use strict;
use Module::Build;

my %arguments = (
    license            => 'perl',
    module_name        => 'Catalyst::Plugin::C3',
    requires           => {
        'NEXT'       => 0.60,
        'Class::C3'  => 0.14,
    },
    build_requires     => {
        'Test::More' => 0.32,
    },
    create_makefile_pl => 'traditional',
    create_readme      => 1,
    add_to_cleanup     => [
        'META.yml', '*.bak', '*.gz', 'Makefile.PL', 'README'
    ],
);

Module::Build->new(%arguments)->create_build_script;
