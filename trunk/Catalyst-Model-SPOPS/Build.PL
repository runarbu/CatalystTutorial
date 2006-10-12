use strict;
use Module::Build;

my %arguments = (
    create_makefile_pl => 'passthrough',
    license            => 'perl',
    module_name        => 'Catalyst::Model::SPOPS',
    requires           => {
        'Catalyst' => 5.20,
        'SPOPS'    => 0.87
    },
    create_makefile_pl => 'passthrough',
    test_files         => [ glob('t/*.t') ],
    create_readme      => 1,
);

Module::Build->new(%arguments)->create_build_script;
