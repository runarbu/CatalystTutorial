use inc::Module::Install;

name('Catalyst-Plugin-Authentication-Store-LDAP');
abstract('Authenticate Users against LDAP Directories');
author('Adam Jacob <holoway@cpan.org>');
version_from('lib/Catalyst/Plugin/Authentication/Store/LDAP.pm');
license('perl');

requires('Net::LDAP');
requires('Catalyst::Plugin::Authentication');
build_requires('Test::More');

auto_install();

&WriteAll;

