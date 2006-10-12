use strict;
use Module::Build;

my %arguments = (
    create_makefile_pl => 'passthrough',
    license            => 'perl',
    module_name        => 'Image::Simple',
    requires           => {
        'Image::Math::Constrain' => 0
    },
    create_makefile_pl => 'passthrough',
    test_files         => [ glob('t/*.t'), glob('t/cdbi-t/*.t') ]
);

Module::Build->new(%arguments)->create_build_script;
