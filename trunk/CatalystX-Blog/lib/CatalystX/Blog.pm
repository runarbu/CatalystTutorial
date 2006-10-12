package CatalystX::Blog;

use strict;
use Catalyst qw[ Static Unicode ];

our $VERSION = '0.01';

CatalystX::Blog->config(
    name => __PACKAGE__,
    root => '/Users/chansen/svn/Catalyst/trunk/CatalystX-Blog/root'
);

CatalystX::Blog->setup;

CatalystX::Blog::Model::CDBI->connection('DBI:mysql:test:luther.ngmedia.net');

1;
