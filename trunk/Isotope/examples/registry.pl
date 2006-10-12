#!/usr/bin/perl

use strict;
use warnings;

use Isotope::Application;
use Isotope::Dispatcher::Callback;
use Isotope::Engine::ModPerl;

our $application ||= Isotope::Application->new(
    engine     => Isotope::Engine::ModPerl->new,
    dispatcher => Isotope::Dispatcher::Callback->new( callback => sub {
        my ( $dispatcher, $transaction ) = @_;
        $transaction->response->content_type('text/plain');
        $transaction->response->content('Hello World!');
    })
)->setup;

$application->run(@_);
