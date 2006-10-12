use strict;
use Catalyst::Build;

my $build = Catalyst::Build->new(
    create_makefile_pl => 'passthrough',
    license            => 'perl',
    module_name        => 'BookDB',
    requires           => { Catalyst                          => '5.10',
			    'Catalyst::View::TT'              => 0,
			    'Catalyst::Model::CDBI'           => 0,
			    'Template::Plugin::Class'         => 0,
			    'Net::Amazon'	              => 0,
			    'Catalyst::Plugin::DefaultEnd'    => 0,
			    'Catalyst::Plugin::FillInForm'    => 0,
			    'Catalyst::Plugin::FormValidator' => 0,
    create_makefile_pl => 'passthrough',
    script_files       => [ glob('script/*') ],
    test_files         => [ glob('t/*.t'), glob('t/*/*.t') ]
);
$build->create_build_script;
