package TestApp;

use strict;
use Catalyst qw/
    Session
    Session::Store::Dummy
    Test::Errors 
    Test::Headers 
    Test::Plugin
/;
use Catalyst::Utils;

our $VERSION = '0.01';

TestApp->config( name => 'TestApp', root => '/some/dir', session => { param => 'sid', rewrite => 0 } );

TestApp->setup(qw/Session::State::URI/);

{
    no warnings 'redefine';
    sub Catalyst::Log::error { }
}
1;
