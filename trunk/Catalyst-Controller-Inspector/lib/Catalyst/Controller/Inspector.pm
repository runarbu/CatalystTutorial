package Catalyst::Controller::Inspector;

use strict;
use warnings;

use base qw( Catalyst::Controller Class::Accessor::Fast );

use Module::Find;
use Tree::Simple;
use Pod::Find qw( pod_where );
use Pod::Xhtml;
use File::Slurp;
use HTML::Entities;

our $VERSION = '0.01';

__PACKAGE__->mk_accessors( qw( catalyst_doctree ) );

sub inspect : Local {
    my( $self, $c, @args ) = @_;

    $c->response->content_type( 'text/html; charset=utf-8' );

    return $self->index( $c ) unless @args;
    return $self->view( $c, @args );
}

sub index {
    my( $self, $c ) = @_;

    my( $title, $appinfo ) = $self->app_info( $c );
    my( $catinfo ) = $self->catalyst_info( $c );

    $c->res->body( $self->wrap( $title, $appinfo . $catinfo ) );
}

sub view {
    my( $self, $c, @args ) = @_;
    my $module = join( '::', @args );

    my $method  = 'get_' . ( $c->req->param( 'mode' ) || 'pod' );
    $method     = 'get_pod' unless $self->can( $method );

    my $buttons = '';
    for( qw( pod source ) ) {
        $buttons .= '<li';
        if( $method eq 'get_' . $_ ) {
             $buttons .= ' class="selected"';
        }
        my $title = ucfirst $_;
        $buttons .= "><a href=\"?mode=$_\">View $title</a></li>\n";
    }

    my $content = $self->$method( $module );

    $c->res->body( $self->wrap( $module, <<EOPOD ) );
        <div id="docs" class="wrapper">
             <div class="topbar">
                <h1>$module</h1>
             </div>
             <ul id="source">
$buttons
             </ul>
             <div class="content">
$content
             </div>
        </div>
EOPOD
}

sub get_source {
    my $self     = shift;
    my $module   = shift;

    return '<code><pre>' . encode_entities( scalar read_file( $self->find_location( $module ) ) ) . '</pre></code>';
}

sub get_pod {
    my $self     = shift;
    my $module   = shift;
    my $parser   = Pod::Xhtml->new( StringMode => 1, FragmentOnly => 1, MakeIndex => 0, TopLinks => 0 );

    $parser->parse_from_file( $self->find_location( $module ) );

    return $parser->asString;
}

sub find_location {
    my $self   = shift;
    my $module = shift;

    return pod_where( { -inc => 1 }, $module );
}

sub app_info {
    my( $self, $c ) = @_;
    my $name        = Catalyst::Utils::class2appclass( $self );
    my $version     = eval "\$${name}::VERSION";
    my $title       = $name . ( $version ? " $version" : '' );
    my $appaction   = $c->uri_for( $c->req->match, split( /::/, $name ) );

    my $components  = $c->components;

    my( $controllers, $models, $views, $plugins ) = ( '' ) x 4;
    my @plugins = grep { s/\//::/g; s/\.pm//g; /^Catalyst\:\:Plugin\:\:/ } sort keys %INC;
    for my $class ( sort( keys( %$components ), @plugins ) ) {
        my $suffix;
        if( ( $suffix = $class ) =~ s/^Catalyst\:\://  ) {
        }
        else {
            $suffix = Catalyst::Utils::class2classsuffix( $class );
        }

        next unless $suffix;

	my $uri = $c->uri_for( $c->req->match, split( '::', $class ) );
        if( $suffix =~ s/^C(ontroller)?::// ) {
            $controllers .= "<li><a href=\"$uri\">$suffix</a></li>";
        }
        elsif ( $suffix =~ s/^M(odel)?::// ) {
            $models .= "<li><a href=\"$uri\">$suffix</a></li>";
        }
        elsif ( $suffix =~ s/^V(iew)?::// ) {
            $views .= "<li><a href=\"$uri\">$suffix</a></li>";
        }
        elsif ( $suffix =~ s/^Plugin::// ) {
            $plugins .= "<li><a href=\"$uri\">$suffix</a></li>";
        }
    }

    $controllers = "<ul>$controllers</ul>" if $controllers;
    $models      = "<ul>$models</ul>" if $models;
    $views       = "<ul>$views</ul>" if $views;
    $plugins     = "<ul>$plugins</ul>" if $plugins;

    return( $title, <<EOAPPINFO );
        <div id="app" class="wrapper">
             <div class="topbar">
                <h1><a href="$appaction">$name</a> $version</h1>
             </div>
             <div class="content">
                 <h2>Application Class</h2>
                     <ul>
                         <li><a href="$appaction">$name</a></li>
                     </ul>
                 <h2>Controllers</h2>
$controllers
                 <h2>Models</h2>
$models
                 <h2>Views</h2>
$views
                 <h2>Plugins</h2>
$plugins
             </div>
        </div>
EOAPPINFO
}

sub catalyst_info {
    my( $self, $c ) = @_;

    my $tree       = $self->catalyst_doctree || $self->generate_catalyst_doctree( $c );

    return( <<EOCATINFO );
        <div id="catalyst" class="wrapper">
             <div class="topbar">
                <h1><a href="Catalyst">Catalyst</a> $Catalyst::VERSION</h1>
             </div>
             <div class="content">
		<h2>Documentation *</h2>
$tree
                <p>* Class names in <span style="font-weight: bold;">bold</span> are in use in this application.</p>
             </div>
        </div>
EOCATINFO
}

sub generate_catalyst_doctree {
    my( $self, $c ) = @_;
    my $tree        = Tree::Simple->new;
    my @classes     = sort( 'Catalyst', findallmod( 'Catalyst' ) );

    {
        my %cache = ();

        foreach my $class ( sort @classes ) {

            my $parent = $tree;
            my @spaces = split( /::/, $class );

            for ( my $i = 0 ; $i < @spaces ; $i++ ) {

                my $path = join( '::', @spaces[ 0 .. $i ] );

                unless ( exists $cache{$path} ) {
                    my $node = Tree::Simple->new( $spaces[$i] );
                    $parent->addChild($node);
                    $cache{$path} = $node;
                }

                $parent = $cache{$path};
            }
        }
    }

    my %loaded  = map { $_ => 1 } grep { s/\//::/g; s/\.pm//g; /^Catalyst/ } sort keys %INC;
    my $doctree = '<ul id="catdocs">' . $self->tree_to_list( $c, \%loaded, $tree->getChild( 0 ) ) . '</ul>';

    $self->catalyst_doctree( $doctree );
}

sub tree_to_list {
    my $self   = shift;
    my $c      = shift;
    my $loaded = shift;
    my $tree   = shift;
    my @action = @_;
    my $value  = $tree->getNodeValue;

    push @action, $value;

    my $class = join( '::', @action );
    my $attr  = $loaded->{ $class } ? ' class="loaded"' : '';
    my $html  = "<li$attr><a href=\"" . $c->uri_for( $c->req->match, @action ) . "\">$value</a>";

    if( my @children = $tree->getAllChildren ) {
         $html .= '<ul>';
         $html .= $self->tree_to_list( $c, $loaded, $_, @action ) for @children;
         $html .= '</ul>';
    }
    $html    .= '</li>';

    return $html;
}

sub wrap {
    my( $self, $title, $content ) = @_;
    my $css = $self->css;
    return <<"EOWRAP";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
	<meta http-equiv="Content-Language" content="en" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>$title</title>
        <style type="text/css">
$css
        </style>
    </head>
    <body>
$content
    </body>
</html>
EOWRAP
}

sub css {
    return <<EOCSS;
body {
    color: #000;
    background-color: #eee;
    font-family: verdana, tahoma, sans-serif;
}
.wrapper {
    background-color: #ccc;
    border: 1px solid #aaa;
    -moz-border-radius: 10px;
}
#app.wrapper, #catalyst.wrapper {
    display: inline;
    float: left;
    margin-left: 2%;
    margin-bottom: 10px;
}
#app.wrapper {
    width: 54%;
}
#catalyst.wrapper {
    width: 40%;
    background-color: #ddd;
}
#docs.wrapper {
    clear: both;
    width: 96%;
    margin-left: auto;
    margin-right: auto;
}
p, h1, h2, h3, dl {
    margin-left: 20px;
    margin-right: 20px;
}
ul {
    margin-left: 40px;
    padding-left: 0;
    margin-right: 20px;
    list-style-type: none;
}
li {
    font-weight: normal;
    margin-left: 0;
    margin-bottom: 5px;
    padding-left: 0;
}
li.loaded {
    font-weight: bold;
}
ul li ul {
    margin-left: 40px;
	margin-top: 5px;
}
:link, :visited {
    text-decoration: none;
    color: #b00;
    border-bottom: 1px dotted #bbb;
}
:link:hover, :visited:hover {
    color: #555;
}
div.topbar {
    margin: 0px;
}
pre {
    margin: 10px;
    padding: 8px;
}
div.content {
    padding: 8px;
    margin: 0 10px 10px 10px;
    background-color: #fff;
    border: 1px solid #aaa;
    -moz-border-radius: 10px;
}
h1 {
    font-size: medium;
    font-weight: bold;
    text-align: center;
}
.pod h1 {
    text-align: left;
    color: #b00;
    border-bottom: 1px solid #ddd;
}
h2 {
    font-size: 0.9em;
}
h3 {
    font-size: 0.8em;
}
p {
    font-size: 0.9em;
}
ul#source {
    margin-bottom: 3px;
    padding-bottom: 0;
}
ul#source li {
    display: inline;
}
ul#source li a {
    width: 15em;
    padding: 3px 4px;
    background-color: #eee;
    border: 1px solid #aaa;
    -moz-border-radius-topleft: 8px;
    -moz-border-radius-topright: 8px;
}
ul#source li.selected a {
    background-color: #fff;
}
.topbar h1 {
    margin-top: 0.8em;
}

EOCSS
}

sub register_actions {
    my( $self, $c ) = @_;

    return unless $c->debug;
    $self->SUPER::register_actions( $c );
}

sub action_namespace {
    return ''
}

1;