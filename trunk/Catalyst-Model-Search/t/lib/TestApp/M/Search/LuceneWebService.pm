package TestApp::M::Search::LuceneWebService;

use strict;
use base qw/Catalyst::Model::Search::LuceneWebService/;

__PACKAGE__->config(
    # change debug to 1 to see the XML to/from the service
    debug => 0,
);

1;

