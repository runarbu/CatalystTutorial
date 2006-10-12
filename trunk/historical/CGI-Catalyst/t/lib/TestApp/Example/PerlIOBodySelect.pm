package TestApp::Example::PerlIOBodySelect;

use strict;
use base qw[CGI::Catalyst];

use PerlIOBody;

sub prepare {
    my $self = shift;

    $self->response->body( PerlIOBody->new );

    # make body the default stdout
    select( $self->response->body );

    # call the next prepare method
    $self->SUPER::prepare(@_);
}

sub finalize {
    my $self = shift;

    # restore stdout
    select( STDOUT );

    $self->SUPER::finalize(@_);
}

sub begin : Private {
    my $self = shift;
    print 'begin';
}

sub default : Private {
    my $self = shift;
    print 'default';
}

sub end : Private {
    my $self = shift;
    print 'end';
}

1;
