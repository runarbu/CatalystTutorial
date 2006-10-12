#!/usr/bin/perl
# 02-preregister.t 
# Copyright (c) 2006 Jonathan Rockway <jrockway@cpan.org>

use strict;
use warnings;
use Test::More tests => 6;
BEGIN { use_ok('Catalyst::Model::XML::Feed'); }

my $model = Catalyst::Model::XML::Feed->
  new(undef, 
      {feeds => [
		 {title => 'delicious', uri => 'http://del.icio.us/rss/'},
		 {location => 'http://blog.jrock.us/'},
		]
      },
     );

ok($model, 'created model');
ok(scalar $model->get_all_feeds > 2, 'at least two feeds added');

my $d;
eval {
    $d = $model->get('delicious');
};
ok(!$@, 'got feed ok');
isa_ok($d, 'XML::Feed');
ok($d->title, 'delicious');

