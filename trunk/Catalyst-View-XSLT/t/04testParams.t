use strict;
use warnings;
use Test::More tests => 5;

use FindBin;
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/lib";

use_ok('Catalyst::Test', 'TestApp');

my $view = 'XML::LibXSLT';

my $response;
ok(($response = request("/testParams?view=$view&template=testParams.xsl"))->is_success, 'request ok');
is($response->content, TestApp->config->{default_message}, 'message ok');

my $message = scalar localtime;
ok(($response = request("/testParams?view=$view&message=$message&template=testParams.xsl"))->is_success, 'request with message ok');
is($response->content, $message, 'message ok');
