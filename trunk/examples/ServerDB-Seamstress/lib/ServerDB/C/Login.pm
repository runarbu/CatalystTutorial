package ServerDB::C::Login;

use strict;
use base 'Catalyst::Base';

sub default : Private {
  my ($self, $c) = @_;
  $c->forward('login');
}

#
sub login : Path('/login') {
  my ( $self, $c ) = @_;

	
#  $c->stash->{template} = "login.xhtml";
  $c->stash->{LOOM} = "root::login";

  if ($c->req->params->{username}) {
    $c->session_login(
      $c->req->params->{username},
      $c->req->params->{password}
     );
  } else {
    # save the referring page so we can redirect back
    $c->session->{referer} = $c->req->path;
  }
	
  if ($c->req->{user}) {
    my $target =
	($c->session->{referer} =~ m!(login|^$)!)
	    ? '/server/list'
		: $c->session->{referer} ;

    $c->res->redirect( $target ) ;
  }

}

sub logout : Path('/logout') {
	my ($self, $c) = @_;
	
	$c->session_logout if ($c->req->{user});
	$c->res->redirect('/server/list');
}

1;
