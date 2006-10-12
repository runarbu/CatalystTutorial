use strict;
use Module::Build;

my $build = Module::Build->new(
    create_makefile_pl => 'traditional',
    license            => 'perl',
    module_name        => 'Catalyst::View::TT::FunctionGenerator',
    requires           => {
        'perl'               => '5.8.1',
        'Catalyst'           => '5.61',
        'Catalyst::View::TT' => '0.22',
    },
    create_readme => 1,
    sign          => 1,
);
$build->create_build_script;

