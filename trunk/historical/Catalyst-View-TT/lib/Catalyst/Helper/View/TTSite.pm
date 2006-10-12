package Catalyst::Helper::View::TTSite;

use strict;
use File::Spec;

sub mk_compclass {
    my ( $self, $helper, @args ) = @_;
    my $file = $helper->{file};
    $helper->render_file( 'compclass', $file );
    $self->mk_templates( $helper, @args );
}

sub mk_templates {
    my ( $self, $helper ) = @_;
    my $base = $helper->{base},;
    my $ldir = File::Spec->catfile( $base, 'root', 'lib' );
    my $sdir = File::Spec->catfile( $base, 'root', 'src' );

    $helper->mk_dir($ldir);
    $helper->mk_dir($sdir);

    my $dir = File::Spec->catfile( $ldir, 'config' );
    $helper->mk_dir($dir);

    foreach my $file (qw( main col url )) {
        $helper->render_file( "config_$file",
            File::Spec->catfile( $dir, $file ) );
    }

    $dir = File::Spec->catfile( $ldir, 'site' );
    $helper->mk_dir($dir);

    foreach my $file (qw( wrapper layout html header footer )) {
        $helper->render_file( "site_$file",
            File::Spec->catfile( $dir, $file ) );
    }

    foreach my $file (qw( welcome.tt2 message.tt2 error.tt2 ttsite.css )) {
        $helper->render_file( $file, File::Spec->catfile( $sdir, $file ) );
    }

}

=head1 NAME

Catalyst::Helper::View::TTSite - Helper for TT view which builds a skeleton web site

=head1 SYNOPSIS

# use the helper to create the view module and templates

    $ script/myapp_create.pl view TT TTSite

# add something like the following to your main application module

    sub message : Global {
        my ( $self, $c ) = @_;
        $c->stash->{template} = 'message.tt2';
        $c->stash->{message}  ||= $c->req->param('message') || 'No message';
    }
    
    sub default : Private {
        my ( $self, $c ) = @_;
        $c->stash->{template} = 'welcome.tt2';
    }
    
    sub end : Private {
        my ( $self, $c ) = @_;
        $c->forward('MyApp::V::TT');
    }

=head1 DESCRIPTION

This helper module creates a TT View module.  It goes further than
Catalyst::Helper::View::TT in that it additionally creates a simple
set of templates to get you started with your web site presentation.

It creates the templates in a F<templates> directory underneath your
main project directory.  In here two further subdirectories are
created: F<src> which contains the main page templates, and F<lib>
containing a library of other templates components (header, footer,
etc.) that the page templates use.

The view module that the helper creates is automatically configured
to locate these templates.

=head2 METHODS

=head3 mk_compclass

Generates the component class.

=head3 mk_templates

Generates the templates.

=cut

=head1 SEE ALSO

L<Catalyst>, L<Catalyst::View::TT>, L<Catalyst::Helper>,
L<Catalyst::Helper::View::TT>

=head1 AUTHOR

Andy Wardley <abw@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;

__DATA__

__compclass__
package [% class %];

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config({
    CATALYST_VAR => 'Catalyst',
    INCLUDE_PATH => [
        [% app %]->path_to( 'root', 'src' ),
        [% app %]->path_to( 'root', 'lib' )
    ],
    PRE_PROCESS  => 'config/main',
    WRAPPER      => 'site/wrapper',
    ERROR        => 'error.tt2',
    TIMER        => 0
});

=head1 NAME

[% class %] - Catalyst TTSite View

=head1 SYNOPSIS

See L<[% app %]>

=head1 DESCRIPTION

Catalyst TTSite View.

=head1 AUTHOR

[% author %]

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

__config_main__
[% USE Date;
   year = Date.format(Date.now, '%Y');
-%]
[% TAGS star -%]
[% # config/main
   #
   # This is the main configuration template which is processed before
   # any other page, by virtue of it being defined as a PRE_PROCESS 
   # template.  This is the place to define any extra template variables,
   # macros, load plugins, and perform any other template setup.

   IF Catalyst.debug;
     # define a debug() macro directed to Catalyst's log
     MACRO debug(message) CALL Catalyst.log.debug(message);
   END;

   # define a data structure to hold sitewide data
   site = {
     title     => 'Catalyst::View::TTSite Example Page',
     copyright => '[* year *] Your Name Here',
   };

   # load up any other configuration items 
   PROCESS config/col
         + config/url;

   # set defaults for variables, etc.
   DEFAULT 
     message = 'There is no message';

-%]
__config_col__
[% TAGS star -%]
[% site.rgb = {
     black  = '#000000'
     white  = '#ffffff'
     grey1  = '#46494c'
     grey2  = '#c6c9cc'
     grey3  = '#e3e6ea'
     red    = '#CC4444'
     green  = '#66AA66'
     blue   = '#89b8df'
     orange = '#f08900'
   };

   site.col = {
      page    = site.rgb.white
      text    = site.rgb.grey1
      head    = site.rgb.grey3
      line    = site.rgb.orange
      message = site.rgb.green
      error   = site.rgb.red
   };
%]
__config_url__
[% TAGS star -%]
[% base = Catalyst.req.base;

   site.url = {
     base    = base
     home    = "${base}welcome"
     message = "${base}message"
   }
-%]
__site_wrapper__
[% TAGS star -%]
[% IF template.name.match('\.(css|js|txt)');
     debug("Passing page through as text: $template.name");
     content;
   ELSE;
     debug("Applying HTML page layout wrappers to $template.name\n");
     content WRAPPER site/html + site/layout;
   END;
-%]
__site_html__
[% TAGS star -%]
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
 <head>
  <title>[% template.title or site.title %]</title>
  <style type="text/css">
[% PROCESS ttsite.css %]
  </style>
 </head>
 <body>
[% content %]
 </body>
</html>
__site_layout__
[% TAGS star -%]
<div id="header">[% PROCESS site/header %]</div>

<div id="content">
[% content %]
</div>

<div id="footer">[% PROCESS site/footer %]</div>
__site_header__
[% TAGS star -%]
<!-- BEGIN site/header -->
<h1 class="title">[% template.title or site.title %]</h1>
<!-- END site/header -->
__site_footer__
[% TAGS star -%]
<!-- BEGIN site/footer -->
<div id="copyright">&copy; [% site.copyright %]</div>
<!-- END site/footer -->
__welcome.tt2__
[% TAGS star -%]
[% META title = 'Catalyst/TT View!' %]
<p>
  Yay!  You're looking at a page generated by the Catalyst::View::TT
  plugin module.
</p>
<p>
  This is the welcome page.  Why not try the equally-exciting 
  <a href="[% site.url.message %]">Message Page</a>?
</p>
__message.tt2__
[% TAGS star -%]
[% META title = 'Catalyst/TT View!' %]
<p>
  Yay!  You're looking at a page generated by the Catalyst::View::TT
  plugin module.
</p>
<p>
  We have a message for you: <span class="message">[% message %]</span>.
</p>
<p>
  Why not try updating the message?  Go on, it's really exciting, honest!
</p>
<form action="[% site.url.message %]"
      method="POST" enctype="application/x-www-form-urlencoded">
 <input type="text" name="message" value="[% message %]" />
 <input type="submit" name="submit" value=" Update Message "/>
</form>
__error.tt2__
[% TAGS star -%]
[% META title = 'Catalyst/TT Error' %]
<p>
  An error has occurred.  We're terribly sorry about that, but it's 
  one of those things that happens from time to time.  Let's just 
  hope the developers test everything properly before release...
</p>
<p>
  Here's the error message, on the off-chance that it means something
  to you: <span class="error">[% error %]</span>
</p>
__ttsite.css__
[% TAGS star %]
html {
    height: 100%;
}

body { 
    background-color: [% site.col.page %];
    color: [% site.col.text %];
    margin: 0px;
    padding: 0px;
    height: 100%;
}

#header {
    background-color: [% site.col.head %];
    border-bottom: 1px solid [% site.col.line %];
}

#footer {
    background-color: [% site.col.head %];
    text-align: center;
    border-top: 1px solid [% site.col.line %];
    position: absolute;
    bottom: 0;
    left: 0px;
    width: 100%;
    padding: 4px;
}

#content {
    padding: 10px;
}

h1.title {
    padding: 4px;
    margin: 0px;
}

.message {
    color: [% site.col.message %];
}

.error {
    color: [% site.col.error %];
}
