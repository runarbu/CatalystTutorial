use strict;
use Catalyst::Build;

my $build = Catalyst::Build->new(
    create_makefile_pl => 'passthrough',
    license            => 'perl',
    module_name        => 'Cataculous',
    requires           => {
        Catalyst                    => '5.10',
        Catalyst::Plugin::Prototype => '1.32',
        HTML::Prototype             => '1.32',
        Catalyst::View::TT          => 0
    },
    create_makefile_pl => 'passthrough',
    script_files       => [ glob('script/*') ],
    test_files         => [ glob('t/*.t'), glob('t/*/*.t') ]
);
$build->create_build_script;
