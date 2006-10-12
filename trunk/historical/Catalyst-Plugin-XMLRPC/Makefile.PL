use inc::Module::Install;

name 'Catalyst-Plugin-XMLRPC';
all_from 'lib/Catalyst/Plugin/XMLRPC.pm';

requires Catalyst => '5.66';
requires 'RPC::XML';

auto_install;
WriteAll;
