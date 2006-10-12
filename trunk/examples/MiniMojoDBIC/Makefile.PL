use inc::Module::Install;

name 'MiniMojoDBIC';
all_from 'lib/MiniMojoDBIC.pm';

requires Catalyst => '5.64';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
