use strict;

use Module::Build;

my $build = Module::Build->new(
	module_name        => 'Catalyst::Controller::Inspector',
	dist_author        => 'Brian Cassidy <bricas@cpan.org>',
	license            => 'perl',
	create_readme      => 1,
	create_makefile_pl => 'traditional',
	requires           => {
		'Catalyst'     => 0,
		'File::Slurp'  => 0,
                'Module::Find' => 0,
		'Pod::Find'    => 0,
                'Pod::Xhtml'   => '1.43',
	},
);

$build->create_build_script;