use strict;
use Module::Build;

my %arguments = (
    create_makefile_pl => 'passthrough',
    license            => 'perl',
    module_name        => 'Catalyst::Log::Dispatch::Config',
    requires           => {
        'Catalyst'                => 5.23,
        'Catalyst::Log::Dispatch' => 0,
        'Log::Dispatch::Config'   => 0
    },
    create_makefile_pl => 'passthrough',
    test_files         => [ glob('t/*.t') ]
);

Module::Build->new(%arguments)->create_build_script;
