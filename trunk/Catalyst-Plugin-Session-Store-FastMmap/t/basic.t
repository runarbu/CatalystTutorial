#!/usr/bin/perl

use strict;
use warnings;

use File::Temp;
use File::Spec;

use Catalyst::Plugin::Session::Test::Store (
    backend => "FastMmap",
    config  => {
        storage => ( my $tmp = File::Temp->new( UNLINK => 1 ) )
          ->filename,    # $tmp: positive refcount
    },
);

