#!/usr/bin/perl

use strict;
use warnings;

use Isotope::Application;
use Isotope::Dispatcher::Callback;
use Isotope::Engine::LWP;
use WWW::Mechanize::Isotope;

my $application = Isotope::Application->new(
    engine     => Isotope::Engine::LWP->new( base => 'http://localhost/' ),
    dispatcher => Isotope::Dispatcher::Callback->new( callback => sub {
        my ( $dispatcher, $transaction ) = @_;
        $transaction->response->content_type('text/plain');
        $transaction->response->content('Hello World!');
    })
)->setup;

my $mech = WWW::Mechanize::Isotope->new(
    application => $application 
    cookie_jar  => {}
);

my $response = $mech->get('/path');
