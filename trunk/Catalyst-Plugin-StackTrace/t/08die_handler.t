#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More;

plan tests => 2;
use Catalyst::Test 'TestApp';

open STDERR, '>/dev/null';

# test that an exception in the $SIG{__DIE__} handler doesn't hide the original
# exception
{
  no warnings 'redefine';
  no strict 'refs';

  local *{"Devel::StackTrace::new"} = sub { die "FAILED" };

  ok( my $res = request('http://localhost/foo/not_ok'), 'request ok' );
  my $re = qr{Caught exception in TestApp::Controller::Foo-&gt;crash &quot;Undefined subroutine &amp;TestApp::Controller::Foo::three}s;
  like( $res->content, $re, 'original exception thrown' );
}
