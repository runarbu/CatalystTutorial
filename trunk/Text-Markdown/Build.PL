use strict;
use Module::Build;

my $build = Module::Build->new(
    create_makefile_pl => 'passthrough',
    license            => 'perl',
    module_name        => 'Text::Markdown',
    create_readme      => 1,
    test_files         => [ glob('t/*.t t/*/*.t') ]
);
$build->create_build_script;
