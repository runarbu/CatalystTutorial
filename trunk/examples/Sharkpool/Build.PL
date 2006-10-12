use strict;
use Catalyst::Build;

my $build = Catalyst::Build->new(
    create_makefile_pl => 'passthrough',
    license            => 'perl',
    module_name        => 'Sharkpool',
    requires           => {
        Catalyst                       => '5.10',
        'Catalyst::Model::CDBI::Sweet' => 0,
        'HTML::Prototype'              => 0,
        ' Text::Unaccent '             => 0,
        DateTime                       => 0
    },
    create_makefile_pl => ' passthrough ',
    script_files       => [ glob(' script /*') ],
    test_files         => [ glob('t/ * . t '), glob(' t /*/ * . t ') ]
);
$build->create_build_script;

