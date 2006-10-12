package IM::Controller::Cron;

use strict;
use warnings;

use base qw( Catalyst::Controller );

sub clean_sessions : Local {
    my ( $self, $c ) = @_;
    $c->delete_expired_sessions();
}

1;
