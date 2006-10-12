package TestApp::Controller::Action::Chained::ParentChain;
use warnings;
use strict;

use base qw/ Catalyst::Controller /;

#
#   Chains to the action /action/chained/parentchain in the
#   Action::Chained controller.
#
sub child :Chained('.') :Args(1) { }

1;
