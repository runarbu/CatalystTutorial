use inc::Module::Install;

perl_version '5.8.1';

name 'Catalyst-Helper-HTMLDesign';
all_from 'lib/Catalyst/Helper/HTMLDesign.pm';

requires 'Catalyst' => 0;

auto_install;
WriteAll;
