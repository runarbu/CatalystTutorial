use strict;
use Module::Build;

my %arguments = (
    create_makefile_pl => 'passthrough',
    license            => 'perl',
    module_name        => 'Catalyst::Model::Xapian',
    requires           => {
        'Search::Xapian' => '0.9.2.4',
        'Encode'         => '0',
        'Storable'       => '0',
        'Catalyst'       => '5.30',
        'Data::Page'     => '0',
    },
    create_makefile_pl => 'passthrough',
    test_files         => [ glob('t/*.t') ],
    create_readme      => 1,
);

Module::Build->new(%arguments)->create_build_script;
