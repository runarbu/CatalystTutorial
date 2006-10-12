
use strict;
use warnings;
use inc::Module::Install;

name('Task-Catalyst-Tutorial');
abstract('Everything you need to follow the Catalyst Tutorial');
version_from('lib/Task/Catalyst/Tutorial.pm');
license('perl');
requires( 
	 'Catalyst::Runtime' => '5.7000',
	 'Catalyst::Devel'   => '1.0',
	 'Catalyst::Plugin::Authentication' => 0.09,
	 'Catalyst::Plugin::Authentication::Store::DBIC' => 0.07,
	 'Catalyst::Plugin::Authorization::ACL' => 0.08,
	 'Catalyst::Plugin::Authorization::Roles' => 0.04,
	 'Catalyst::Plugin::ConfigLoader' => 0.13,
	 'Catalyst::Plugin::HTML::Widget' => 1.1,
	 'Catalyst::Plugin::Session' => 0.12,
	 'Catalyst::Plugin::Session::State::Cookie' => 0.05,
	 'Catalyst::Plugin::Session::Store::FastMmap' => 0.02,
	 'Catalyst::Plugin::StackTrace' => 0.06,
	 'Catalyst::Plugin::Static::Simple' => 0.14,
	 'DBIx::Class' => 0,
	 'DBIx::Class::Schema' => 0,
	 'Catalyst::View::TT' => 0,
	 'Catalyst::Model::DBIC::Schema' => 0,
	);
build_requres('Test::More' => 0);
no_index(directory => 'examples');
eval{ install_share('examples') };
auto_install();
WriteAll();
