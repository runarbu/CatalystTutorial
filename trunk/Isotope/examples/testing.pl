#!/usr/bin/perl

use strict;
use warnings;

use Isotope::Application;
use Isotope::Dispatcher::Callback;
use Isotope::Engine::LWP;

my $application = Isotope::Application->new(
    engine     => Isotope::Engine::LWP->new( base => 'http://localhost/' ),
    dispatcher => Isotope::Dispatcher::Callback->new( callback => sub {
        my ( $dispatcher, $transaction ) = @_;
        $transaction->response->content_type('text/plain');
        $transaction->response->content('Hello World!');
    })
)->setup;


use Test::More tests => 2;
use Test::WWW::Mechanize::Isotope;

my $mech = Test::WWW::Mechanize::Isotope->new(
    application => $application 
    cookie_jar  => {}
);

$mech->get_ok('http://localhost/');
$mech->content_contains('Hello World!');
