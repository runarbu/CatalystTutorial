package TestApp::M::Search::Plucene;

use strict;
use base qw/Catalyst::Model::Search::Plucene/;

__PACKAGE__->config(
    index => 't/var/plucene',
);

1;

