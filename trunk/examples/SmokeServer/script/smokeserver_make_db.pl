#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use SmokeDB;

SmokeDB->connect( "dbi:SQLite:dbname=cat_test_smoke.db" )->deploy;

