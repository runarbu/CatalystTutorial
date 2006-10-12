package MyModPerl;

use strict;
use warnings;

use Isotope::Application;
use Isotope::Dispatcher::Callback;
use Isotope::Engine::ModPerl;

my $application = Isotope::Application->new(
    engine     => Isotope::Engine::ModPerl->new,
    dispatcher => Isotope::Dispatcher::Callback->new( callback => sub {
        my ( $dispatcher, $transaction ) = @_;
        $transaction->response->content_type('text/plain');
        $transaction->response->content('Hello World!');
    })
)->setup;

sub handler ($$) : method {
    return $application->run( pop @_ );
}

1;

__END__

# For mod_perl 1.x use SetHandler "perl-script" and PerlHandler instead 
# of PerlResponseHandler.

# A couple of examples on how an app can be "mounted" in httpd.conf 

# $t->request->uri->path  : /a/b/c/
# $t->request->base->path : /
# $t->request->path       : /a/b/c

<VirtualHost "*">
    SetHandler          "modperl"
    PerlResponseHandler MyModPerl
</VirtualHost>


# $t->request->uri->path  : /test/a/b/c/
# $t->request->base->path : /test/
# $t->request->path       : /a/b/c

<Location "/test/">
    SetHandler          "modperl"
    PerlResponseHandler MyModPerl
</Location>


# $t->request->uri->path  : /a/test/b/c/d/
# $t->request->base->path : /a/test/b/
# $t->request->path       : /c/d

<Location "/[a-c]/test/*/">
    SetHandler          "modperl"
    PerlResponseHandler MyModPerl
</Location>


# $t->request->uri->path  : /a/test/c/d/
# $t->request->base->path : /a/test/
# $t->request->path       : /c/d

<LocationMatch "/(a|b)/test/">
    SetHandler          "modperl"
    PerlResponseHandler MyModPerl
</LocationMatch>


# $t->request->uri->path  : /a/test/c/d/
# $t->request->base->path : /a/test/
# $t->request->path       : /c/d

<LocationMatch "/(?:a|b)/test/">
    SetHandler          "modperl"
    PerlResponseHandler MyModPerl
</LocationMatch>
