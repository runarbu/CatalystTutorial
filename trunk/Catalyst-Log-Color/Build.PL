use strict;
use Module::Build;

my %arguments = (
    create_makefile_pl => 'passthrough',
    license            => 'perl',
    module_name        => 'Catalyst::Log::Color',
    requires           => {
        'Catalyst'          => 5.23,
    },
    create_makefile_pl => 'passthrough',
    test_files         => [ glob('t/*.t') ]
);

if ( $^O eq 'MSWin32' ) {
    $arguments{requires}->{'Win32::Console::ANSI'} = 0;
}

Module::Build->new(%arguments)->create_build_script;
