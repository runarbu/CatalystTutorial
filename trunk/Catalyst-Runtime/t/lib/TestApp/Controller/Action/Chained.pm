package TestApp::Controller::Action::Chained;

use strict;
use warnings;

use base qw/Catalyst::Controller/;

sub begin :Private { }

#
#   TODO
#   :Chained('') means what?
#

#
#   Simple parent/child action test
#
sub foo  :PathPart('chained/foo')  :CaptureArgs(1) :Chained('/') { }
sub endpoint  :PathPart('end')  :Chained('/action/chained/foo')  :Args(1) { }

#
#   Parent/child test with two args each
#
sub foo2 :PathPart('chained/foo2') :CaptureArgs(2) :Chained('/') { }
sub endpoint2 :PathPart('end2') :Chained('/action/chained/foo2') :Args(2) { }

#
#   Relative specification of parent action
#
sub bar :PathPart('chained/bar') :Chained('/') :CaptureArgs(0) { }
sub finale :PathPart('') :Chained('bar') :Args { }

#
#   three chain with concurrent endpoints
#
sub one   :PathPart('chained/one') :Chained('/')                   :CaptureArgs(1) { }
sub two   :PathPart('two')         :Chained('/action/chained/one') :CaptureArgs(2) { }
sub three_end :PathPart('three')       :Chained('two') :Args(3) { }
sub one_end   :PathPart('chained/one') :Chained('/')   :Args(1) { }
sub two_end   :PathPart('two')         :Chained('one') :Args(2) { }

#
#   Dispatch on number of arguments
#
sub multi1 :PathPart('chained/multi') :Chained('/') :Args(1) { }
sub multi2 :PathPart('chained/multi') :Chained('/') :Args(2) { }

#
#   Roots in an action defined in a higher controller
#
sub higher_root :PathPart('bar') :Chained('/action/chained/foo/higher_root') :Args(1) { }

#
#   Controller -> subcontroller -> controller
#
sub pcp1 :PathPart('chained/pcp1')  :Chained('/')                        :CaptureArgs(1) { }
sub pcp3 :Chained('/action/chained/foo/pcp2') :Args(1)     { }

#
#   Dispatch on capture number
#
sub multi_cap1 :PathPart('chained/multi_cap') :Chained('/') :CaptureArgs(1) { }
sub multi_cap2 :PathPart('chained/multi_cap') :Chained('/') :CaptureArgs(2) { }
sub multi_cap_end1 :PathPart('baz') :Chained('multi_cap1') :Args(0) { }
sub multi_cap_end2 :PathPart('baz') :Chained('multi_cap2') :Args(0) { }

#
#   Priority: Slurpy args vs. chained actions
#
sub priority_a1 :PathPart('chained/priority_a') :Chained('/') :Args { }
sub priority_a2 :PathPart('chained/priority_a') :Chained('/') :CaptureArgs(1) { }
sub priority_a2_end :PathPart('end') :Chained('priority_a2') :Args(1) { }


#
#   Priority: Fixed args vs. chained actions
#
sub priority_b1 :PathPart('chained/priority_b') :Chained('/') :Args(3) { }
sub priority_b2 :PathPart('chained/priority_b') :Chained('/') :CaptureArgs(1) { }
sub priority_b2_end :PathPart('end') :Chained('priority_b2') :Args(1) { }

#
#   Priority: With no Args()
#
sub priority_c1 :PathPart('chained/priority_c') :Chained('/') :CaptureArgs(1) { }
sub priority_c2 :PathPart('') :Chained('priority_c1') { }
sub priority_c2_xyz :PathPart('xyz') :Chained('priority_c1')  { }


#
#   Optional specification of :Args in endpoint
#
sub opt_args :PathPart('chained/opt_args') :Chained('/') { }

#
#   Optional PathPart test -> /chained/optpp/*/opt_pathpart/*
#
sub opt_pp_start :Chained('/') :PathPart('chained/optpp') :CaptureArgs(1) { }
sub opt_pathpart :Chained('opt_pp_start') :Args(1) { }

#
#   Optional Args *and* PathPart -> /chained/optall/*/oa/...
#
sub opt_all_start :Chained('/') :PathPart('chained/optall') :CaptureArgs(1) { }
sub oa :Chained('opt_all_start') { }

#
#   :Chained is the same as :Chained('/')
#
sub rootdef :Chained :PathPart('chained/rootdef') :Args(1) { }

#
#   the ParentChain controller chains to this action by
#   specifying :Chained('.')
#
sub parentchain :Chained('/') :PathPart('chained/parentchain') :CaptureArgs(1) { }

#
#   This is just for a test that a loose end is not callable
#
sub loose :Chained :PathPart('chained/loose') CaptureArgs(1) { }

#
#   Forwarding out of the middle of a chain.
#
sub chain_fw_a :Chained :PathPart('chained/chain_fw') :CaptureArgs(1) {
    $_[1]->forward( '/action/chained/fw_dt_target' );
}
sub chain_fw_b :Chained('chain_fw_a') :PathPart('end') :Args(1) { }

#
#   Detaching out of the middle of a chain.
#
sub chain_dt_a :Chained :PathPart('chained/chain_dt') :CaptureArgs(1) {
    $_[1]->detach( '/action/chained/fw_dt_target' );
}
sub chain_dt_b :Chained('chain_dt_a') :PathPart('end') :Args(1) { }

#
#   Target for former forward and chain tests.
#
sub fw_dt_target :Private { }

#
#   Test multiple chained actions with no captures
#
sub empty_chain_a : Chained('/')             PathPart('chained/empty') CaptureArgs(0) { }
sub empty_chain_b : Chained('empty_chain_a') PathPart('')              CaptureArgs(0) { }
sub empty_chain_c : Chained('empty_chain_b') PathPart('')              CaptureArgs(0) { }
sub empty_chain_d : Chained('empty_chain_c') PathPart('')              CaptureArgs(1) { }
sub empty_chain_e : Chained('empty_chain_d') PathPart('')              CaptureArgs(0) { }
sub empty_chain_f : Chained('empty_chain_e') PathPart('')              Args(1)        { }

sub end :Private {
  my ($self, $c) = @_;
  my $out = join('; ', map { join(', ', @$_) }
                         ($c->req->captures, $c->req->args));
  $c->res->body($out);
}

1;
