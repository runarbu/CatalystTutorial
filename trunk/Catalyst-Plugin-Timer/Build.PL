use strict;
use Module::Build;

my %arguments = (
    create_makefile_pl => 'passthrough',
    license            => 'perl',
    module_name        => 'Catalyst::Plugin::Timer',
    requires           => {
			   'Catalyst' => 5.33,
			   'Time::HiRes' => 0,
			  },
    create_readme      => 1,
    test_files         => [ glob('t/*.t') ]
);

Module::Build->new(%arguments)->create_build_script;

