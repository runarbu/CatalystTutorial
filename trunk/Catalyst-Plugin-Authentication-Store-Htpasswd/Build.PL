use strict;
use Module::Build;

my $build = Module::Build->new(
    create_makefile_pl  => 'traditional',
    license             => 'perl',
    create_readme       => 1,
    
    module_name         => 'Catalyst::Plugin::Authentication::Store::Htpasswd',
    requires            => {
        'Catalyst::Plugin::Authentication' => '0.01',
        'Authen::Htpasswd' => '0.13',
    },

    dist_author => 'David Kamholz <dkamholz@cpan.org>',
);
$build->create_build_script;

