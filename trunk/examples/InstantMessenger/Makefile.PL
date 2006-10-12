use inc::Module::Install;

name 'IM';
all_from 'lib/IM.pm';

requires Catalyst => '5.62';
requires Catalyst::Plugin::DefaultEnd;
requires Catalyst::Plugin::Session;
requires Catalyst::Plugin::Session::Store::DBI;
requires Catalyst::Plugin::Session::State::Cookie;
requires Catalyst::Plugin::Scheduler;
requires Catalyst::Controller::BindLex;

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
