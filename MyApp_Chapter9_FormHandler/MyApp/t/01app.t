#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'MyApp' }

ok( request('/login')->is_success, 'Request should succeed' );

done_testing();
