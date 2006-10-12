#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More tests => 17;
use CGI::Catalyst::Test 'TestApp';

use attributes;

{
    ok( my $code = TestApp->can('begin'), 'begin' );
    is_deeply( [ attributes::get($code) ], [ 'Private' ], 'Attributes for begin' );
    ok( my $action = $CGI::Catalyst::ACTIONS->{"$code"}, 'ACTION for begin code' );
    is( $action->[0], 'TestApp', 'ACTIONS package for begin' );
    is( $action->[1], $code, 'ACTIONS CODE for begin' );
    is( $action->[2]->[0], 'Private', 'ACTIONS attrubutes for begin' );
    is( $action->[3], 'begin', 'ACTIONS method name for begin' );
    is( TestApp->actions->{'begin'}, $code, 'action' );
}

{
    ok( my $code = TestApp->can('two'), 'two' );
    is_deeply( [ attributes::get($code) ], [ "Path('/errors/two')" ], 'Attributes for two' );
    ok( my $action = $CGI::Catalyst::ACTIONS->{"$code"}, 'ACTION for two code' );
    is( $action->[0], 'TestApp', 'ACTIONS package for two' );
    is( $action->[1], $code, 'ACTIONS CODE for two' );
    is( $action->[2]->[0], "Path('/errors/two')", 'ACTIONS attrubutes for two' );
    is( $action->[3], 'two', 'ACTIONS method name for begin' );
    is( TestApp->actions->{'/errors/two'}, $code, 'action' );
}

{
    my @expected = qw[
        begin
        /errors/one
        /errors/two
        /errors/three
    ];

    is_deeply( [ sort keys %{ TestApp->actions } ], [ sort @expected ], 'Actions' );
}
