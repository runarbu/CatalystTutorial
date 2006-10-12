package TestApp::Model::DBIC::Session;

eval { require DBIx::Class }; return 1 if $@;
@ISA = qw/TestApp::Model::DBIC/;

use strict;
use warnings;

__PACKAGE__->table('sessions');
__PACKAGE__->add_columns(qw/id data expires/);
__PACKAGE__->set_primary_key('id');

1;
