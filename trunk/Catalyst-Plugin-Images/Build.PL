use strict;
use Module::Build;

my $build = Module::Build->new(
    create_makefile_pl => 'traditional',
    license            => 'perl',
    module_name        => 'Catalyst::Plugin::Images',
    requires           => {
        'perl'           => '5.8.1',
        'Catalyst'       => '5.5',
        'Image::Size'    => 0,
        'Path::Class'    => 0,
        'HTML::Entities' => 0,
    },
    create_readme => 1,
    sign          => 1,
);
$build->create_build_script;

