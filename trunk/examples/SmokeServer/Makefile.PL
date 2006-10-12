use inc::Module::Install;

name 'SmokeServer';
all_from 'lib/SmokeServer.pm';

requires Catalyst => '5.64';
requires 'DBIx::Class' => '0.06999_02';
requires 'Test::TAP::HTMLMatrix' => '0.05';
requires 'HTML::TagCloud' => '0';
requires 'Text::Tags' => '0';
requires 'DateTime' => '0';
requires 'DateTime::Format::ISO8601' => '0';
requires 'Data::Serializer' => '0';
requires 'Time::Duration::Object' => '0';
requires 'Test::use::ok' => '0';
requires 'Catalyst::Plugin::Cache::FastMmap' => '0';
requires 'Catalyst::Plugin::HTML::Widget' => '0';
requires 'Catalyst::Plugin::Session' => '0';
requires 'Catalyst::Plugin::Session::State::Cookie' => '0';
requires 'Catalyst::Plugin::Session::Store::FastMmap' => '0';
requires 'Catalyst::Plugin::Session::Defaults' => '0';
requires 'Catalyst::Model::DBIC::Schema' => '0';
requires 'Catalyst::View::TT::FunctionGenerator' => '0';
requires 'Catalyst::View::JSON' => '0';
requires 'Catalyst::Controller::BindLex' => '0';



catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
