use strict;
use Module::Build;

my $build = Module::Build->new(
    create_makefile_pl => 'traditional',
    license            => 'perl',
    module_name        => 'Catalyst::Controller::BindLex',
    requires           => {
        'perl'            => '5.8.1',
        'Catalyst'        => 0,
        'PadWalker'       => 0,
        'Devel::LexAlias' => 0,
        'Devel::Caller'   => 0,
        'Array::RefElem'  => 0,
        'Test::use::ok'   => 0,
    },
    create_readme => 1,
    sign          => 1,
);
$build->create_build_script;

