package TestApp::Example::CGISession;

use strict;
use base qw[CGI::Catalyst];

use CGI::Session;
use File::Spec;

use constant SESSION_DSN     => 'driver:File;serializer:Storable;id:MD5';
use constant SESSION_OPTIONS => { Directory => File::Spec->tmpdir };

sub prepare_cookies {
    my $self = shift;

    $self->SUPER::prepare_cookies(@_);

    if ( my $cookie = $self->request->cookie('session') ) {
        my $id = $cookie->value;
        $self->{session} = CGI::Session->new( SESSION_DSN, $id, SESSION_OPTIONS );
    }
}

sub finalize_cookies {
    my $self = shift;

    if ( $self->{session} ) {

        my $cookie  = $self->request->cookie('session');
        my $session = $self->{session};

        unless ( $cookie && $cookie->value eq $session->id ) {
            $self->response->cookies->{session} = { value => $session->id };
        }

        $session->close;
    }

    $self->SUPER::finalize_cookies(@_);
}

sub session {
    my $self = shift;

    unless ( $self->{session} ) {
        $self->{session} = CGI::Session->new( SESSION_DSN, undef, SESSION_OPTIONS );
    }

    return $self->{session};
}

sub default : Private {
    my $self = shift;
    
    unless ( $self->session->param('test') ) {
        $self->session->param( 'test' => 'created' );
    }
    
    $self->response->body( $self->session->param('test') );
}

1;
