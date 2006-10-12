use strict;
use Module::Build;

my $build = Module::Build->new(
    license            => 'perl',
    module_name        => 'Isotope',
    requires           => {
        'perl'                     => 5.006,
        'CGI::Cookie'              => 0,
        'Class::MOP'               => 0.26,
        'Clone'                    => 0,
        'Exception::Class'         => 1.23,
        'HTTP::Body'               => 0.6,
        'HTTP::Date'               => 0,
        'HTTP::Headers'            => 1.64,
        'HTTP::Status'             => 0,
        'File::Copy'               => 0,
        'File::Temp'               => 0.14,
        'Moose'                    => 0.05,
        'prefork'                  => 0,
        'Scalar::Util'             => 0,
        'Sub::Exporter'            => 0.952,
        'URI'                      => 0,

        # Isotope::Engine::CGI
        'CGI'                      => 3.11,

        # Isotope::Engine::Daemon
        'HTTP::MessageParser'      => 0.3,
        'IO::String'               => 0,
        'Time::HiRes'              => 0,

        # Isotope::Engine::FastCGI
        'FCGI'                     => 0.67,
        
        # Isotope::Engine::ModPerl
        'mod_perl'                 => 1.24,
        'mod_perl2'                => 1.999022, # RC 5

        # Isotope::Dispatcher::Static 
        'File::MMagic::XS'         => 0.08,
        
        # Isotope::Plugin::Param::Apreq
        'libapreq'                 => 1.33,
        'libapreq2'                => 2.07,
    },
    build_requires     => {
        'Test::More'               => 0,
        'Test::Deep'               => 0,
        'Test::Exception'          => 0,
        'Test::MockObject'         => 0,
    },
    create_makefile_pl => 'traditional',
    create_readme      => 1
);

$build->create_build_script;
