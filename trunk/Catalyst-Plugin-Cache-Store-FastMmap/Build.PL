use strict;
use Module::Build;

my $build = Module::Build->new(
    create_makefile_pl => 'traditional',
    license            => 'perl',
    module_name        => 'Catalyst::Plugin::Cache::Store::FastMmap',
    requires           => {
        'Catalyst'                => '5.7',
        'Catalyst::Plugin::Cache' => '0.01',
        'Cache::FastMmap'         => 0,
        'Path::Class'             => 0,
    },
    create_readme => 1,
    sign          => 1,
);
$build->create_build_script;

