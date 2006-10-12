#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

{

    package MyApp;

    my $c;
    sub context { $c } # singleton API

    sub clear {
        $c = bless {};
    }

    my $moose = bless {}, "Moose";
    sub moose { $moose }

    my $destroyed;
    sub DESTROY {
        $destroyed++;
    }

    sub destroyed { $destroyed }

    __PACKAGE__->clear;

    package MyApp::View::Foo;
    use base qw/Catalyst::View::TT::FunctionGenerator/;

    package Moose;

    sub foo { "magic foo @_" }
    sub bar { "bar" }
}

{
    no warnings 'redefine';
    sub Catalyst::View::TT::template_vars { key => "value" }
}

my $m = "Catalyst::View::TT::FunctionGenerator";
my $v = "MyApp::View::Foo";

can_ok( $m, "template_vars" );

is_deeply(
    { $v->template_vars( MyApp->context ) },
    { key => "value" },
    "template_vars unchanged with no extra data"
);

can_ok( $m, "generate_functions" );

$v->generate_functions("moose");

{
    my $vars = { $v->template_vars( MyApp->context ) };

    is_deeply(
        [ sort keys %$vars ],
        [ sort qw/key foo bar/ ],
        "moose methods added to vars"
    );

    is( ref $vars->{foo},
        "CODE", "the value of the 'foo' variable is a code ref" );

    is(
        $vars->{foo}->(qw/arg1 arg2/),
        MyApp->context->moose->foo(qw/arg1 arg2/),
        "calling foo is like calling MyApp->context->moose->foo"
    );
}

MyApp->clear;

{
    $v->generate_functions( [ moose => "bar" ] );

    my $vars = { $v->template_vars( MyApp->context ) };

    is_deeply( [ sort keys %$vars ], [ sort qw/key bar/ ], "one method added" );

    is(
        $vars->{bar}->(qw/arg1 arg2/),
        MyApp->context->moose->bar(qw/arg1 arg2/),
        "calling bar is like calling MyApp->context->moose->bar"
    );
}

MyApp->clear;


{
    $v->generate_functions( [ MyApp->moose() => "bar" ] );

    my $vars = { $v->template_vars( MyApp->context ) };

    is_deeply( [ sort keys %$vars ], [ sort qw/key bar/ ], "one method added" );

    is(
        $vars->{bar}->(qw/arg1 arg2/),
        MyApp->context->moose->bar(qw/arg1 arg2/),
        "calling bar is like calling MyApp->context->moose->bar"
    );
}

MyApp->clear;

is( MyApp->destroyed, 3, "destroyed count is correct" );

{
    $v->generate_functions( MyApp->context );

    my $vars = { $v->template_vars( MyApp->context ) };
    
    is_deeply( [ sort keys %$vars ], [ sort qw/key context clear moose destroyed DESTROY/ ], 'all methods of $c added' );

    is( $vars->{moose}->(), MyApp->moose, "methods are intact" );
}

is( MyApp->destroyed, 3, "destroyed count is correct" );

MyApp->clear;

is( MyApp->destroyed, 4, "no circular refs");
