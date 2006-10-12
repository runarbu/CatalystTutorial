package Catalyst::Helper::HTMLDesign;

use strict;
use warnings;

our $VERSION = '0.01';

=head1 NAME

Catalyst::Helper::HTMLDesign - Create pre-designed webpage templates.

=head1 SYNOPSIS

    > script/myapp_create.pl HTMLDesign
    > script/myapp_create.pl HTMLDesign layout single
    > script/myapp_create.pl HTMLDesign layout 3column colour corporate
    > script/myapp_create.pl HTMLDesign layout left colour corporate header
    > script/myapp_create.pl HTMLDesign layout right colour corporate header footer

=head1 DESCRIPTION

Get your application looking good fast, by creating blank templates 
with pre-designed xhtml/css layouts.

=head1 OVERVIEW

L<Catalyst::Helper::HTMLDesign|Catalyst::Helper::HTMLDesign> is for use 
with L<Catalyst|Catalyst>, and all commands shown should be typed at a 
command prompt, in your Catalyst application directory.

This documentation assumes you're using the L<TT View|Catalyst::View::TT>. 
Support for other Views may be added, but you can always change the 
Tempate Toolkit syntax to match your chosen View system. In all examples, 
you should replace C<myapp> with the name of your application.

If you haven't already, you should add a View class to your application. 
To add the TT view, type

    script/myapp_create.pl view TT TT

L<Catalyst::Helper::HTMLDesign|Catalyst::Helper::HTMLDesign> will place all 
templates in the C<root> directory of your Catalyst application.

Rather than define an C<end> action in your controller, you can simply use 
the L<Catalyst::Plugin::DefaultEnd|Catalyst::Plugin::DefaultEnd> plugin. 
This will add an C<end> action which will automatically use 
L<Catalyst::View::TT|Catalyst::View::TT> to serve the template files in the 
C<root> directory of your Catalyst application.

To use the L<Catalyst::Plugin::DefaultEnd|Catalyst::Plugin::DefaultEnd> 
plugin, add it to the Catalyst import list in your C<lib/MyApp.pm> file.

    use Catalyst qw/ DefaultEnd /;

L<Catalyst::Helper::HTMLDesign|Catalyst::Helper::HTMLDesign> will create 
the directory C<root/css> if necessary, and will place all CSS stylesheet 
files in it.

To ensure that the CSS file is served, you can use the 
L<Catalyst::Plugin::Static::Simple|Catalyst::Plugin::Static::Simple> 
plugin, just add it to the Catalyst import list in your C<lib/MyApp.pm> 
file, as obove.

    use Catalyst qw/ DefaultEnd StaticSimple /;

=head1 FILES

All filepaths below are within the C<root/> directory within the Catalyst 
application directory.

Depending on the layout chosen, a file will be created named 
C<layout_X.html>, where C<X> is the column layout name. 
You should only need to use 
L<Catalyst::Helper::HTMLDesign|Catalyst::Helper::HTMLDesign> once for each 
layout in each application; it is intended that you copy the 
C<layout_X.html> file as necessary for each new controller.

Depending on the layout chosen, a file will also be created named 
C<lib/wrapper_X.html>, where C<X> is the column layout name. 
There only needs to be 1 copy of each C<lib/wrapper_X.html> file, and any 
content added to it will be visible on any page using the same layout.

Depending on the options used, C<lib/header.html> and C<lib/footer.html> 
files may also be created. There only needs to be 1 copy of each of these 
files. Any content you add to these will be visible sitewide on any page 
using a layout for which the C<header> or C<footer> option was used.

Depending on the layout chosen, a CSS stylesheet file will also be 
created named C<static/css/layout_X.css>, where C<X> is the layout name.

Depending on which colour-scheme is chosen, a CSS stylesheet file will be 
created, with a name like C<static/css/colour_X.css>, where C<X> is the 
colour-scheme name.

Any image files will be saved in C<static/images/>.

=head1 Layouts

=head2 single

By default, a single column layout will be created, with no header or 
footer.

    > script/myapp.pl create HTMLDesign layout default
    created "root/layout_single.html"
    created "root/lib/wrapper_single.html"
    created "root/static/css/layout_single.css"
    created "root/static/css/colour_default.css"
    
    # this is the same as
    
    > script/myapp.pl create HTMLDesign

=head2 left

To create a 2-column layout, with the wider column on the left.

    > script/myapp.pl create HTMLDesign layout left
    created "root/layout_left.html"
    created "root/lib/wrapper_left.html"
    created "root/static/css/layout_left.css"
    created "root/static/css/colour_default.css"

=head2 right

To create a 2-column layout, with the wider column on the right.

    > script/myapp.pl create HTMLDesign layout right
    created "root/layout_right.html"
    created "root/lib/wrapper_right.html"
    created "root/static/css/layout_right.css"
    created "root/static/css/colour_default.css"

=head2 3column

To create a 3-column layout, with a wide central column with a narrower 
column on each side.

For accessibility and search-engine optimisation, the central column will 
be placed before the 2 narrower columns in the xhtml source.

    > script/myapp.pl create HTMLDesign layout 3column
    created "root/layout_3column.html"
    created "root/lib/wrapper_3column.html"
    created "root/static/css/layout_3column.css"
    created "root/static/css/colour_default.css"

=head1 Colour-schemes

=head2 default

    > script/myapp.pl create HTMLDesign layout default colour default
    exists "root"
    created "root/css"
    created "root/layout_single.html"
    created "root/lib/wrapper_single.html"
    created "root/static/css/layout_single.css"
    created "root/static/css/colour_default.css"

=head1 Other Options

=head2 header

Pass the label C<header> for the design to include a header region.

    > script/myapp.pl create HTMLDesign header

=head2 footer

Pass the label C<footer> for the design to include a footer region.

    > script/myapp.pl create HTMLDesign footer

=head1 TODO

More layouts

More colour schemes

=head1 SUPPORT

IRC:

    Join #catalyst on irc.perl.org.

Mailing List:

    http://lists.rawmode.org/mailman/listinfo/catalyst

=head1 SEE ALSO

L<Catalyst>

=head1 AUTHOR

Carl Franks, E<lt>cfranks@cpan.org<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Carl Franks

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
use Data::Dumper;
our @layouts = qw( default single left right 3column );
our @options = qw( header footer );

our %colours = (
    default => {
        page_bg              => '#ffffff',
        text_colour          => '#444444',
        header_bg            => '#96b3df',
        header_border        => '#00569f',
        side_column_bg       => '#f5f5f5',
        side_column_border   => '#c5c5c5',
        left_column_bg       => '#f5f5f5',
        left_column_border   => '#c5c5c5',
        right_column_bg      => '#f5f5f5',
        right_column_border  => '#c5c5c5',
        main_content_bg      => '#f5f5f5',
        main_content_border  => '#c5c5c5',
        footer_bg            => '#96b3df',
        footer_border        => '#00569f',
    },
);
# temporary hack, just so I can test using other colour labels
$colours{corporate} = $colours{default};

# this makes any missing value fallback to the default
# if you want a blank value, use an empty value ''
{
    my @known_keys = keys %{ $colours{default} };
    
    for my $scheme (keys %colours) {
        next if $scheme eq 'default';
        for my $element (@known_keys) {
            next if exists $colours{$scheme}{$element};
            
            $colours{$scheme}{$element} = $colours{default}{$element};
        }
    }
}

sub mk_stuff {
    my ( $self, $helper, @args ) = @_;
    
    my %option = _parse_input( @args );
    
    $self->mk_templates( $helper, %option );
}

sub _parse_input {
    my ( @args ) = @_;
    
    my %option;
    
    while (@args) {
        my $key = shift @args;
        if ($key eq 'layout') {
            $option{layout} = shift @args;
            next;
        }
        elsif ($key eq 'colour' || $key eq 'color') {
            my $colour = shift @args;
            if ( grep {$colour eq $_} keys %colours ) {
                $option{colour} = $colour;
            }
            else {
                warn "unknown colour, using default\n";
                $option{colour} = 'default';
            }
            next;
        }
        elsif ( grep {$key eq $_} @options ) {
            $option{$key} = 1;
        }
        else {
            warn "unknown input value: '$key'\n";
        }
    }
    
    $option{layout} = 'single'  if not exists $option{layout};
    $option{layout} = 'single'  if $option{layout} eq 'default';
    $option{colour} = 'default' if not exists $option{colour};
    
    return %option;
}

sub mk_templates {
    my ( $self, $helper, %option ) = @_;
    
    my $base = $helper->{base},;
    my $libdir = File::Spec->catfile( $base, 'root', 'lib' );
    my $cssdir = File::Spec->catfile( $base, 'root', 'static', 'css' );
    
    $helper->mk_dir($libdir);
    $helper->mk_dir($cssdir);
    
    $self->mk_layout_html( $helper, $base, $libdir, %option );
    
    $self->mk_wrapper_html( $helper, $base, $libdir, %option );
    
    # create lib/header + lib/footer files
    for my $opt (qw/ header footer /) {
        if ( $option{$opt} ) {
            my $data = $helper->get_file( __PACKAGE__, "${opt}_html" );
            
            my $file = File::Spec->catfile(
                $base, 'root', 'lib', "$opt.html" );
            
            $helper->mk_file( $file, $data );
        }
    }
    
    $self->mk_layout_css( $helper, $base, $cssdir, %option );
    
    $self->mk_colour_css( $helper, $base, $cssdir, %option );
}

sub mk_layout_html {
    my ( $self, $helper, $base, $libdir, %option ) = @_;
    
    my $layout = $helper->get_file(
        __PACKAGE__, "layout_$option{layout}_html" );
    
    my $layoutfile = File::Spec->catfile(
        $base, 'root', "layout_$option{layout}.html" );
    
    $helper->mk_file( $layoutfile, $layout );
}

sub mk_wrapper_html {
    my ( $self, $helper, $base, $libdir, %option ) = @_;
    
    my %tmpl = (
        colour_css => 
        qq{[% c.uri_for('/static/css/colour_$option{colour}.css') %]},
        layout_css => 
        qq{[% c.uri_for('/static/css/colour_$option{layout}.css') %]},
    );
    
    $tmpl{header} = <<HEADER if $option{header};

<div id="header">
	[% INCLUDE lib/header.html %]
</div>
HEADER
    
    $tmpl{footer} = <<FOOTER if $option{footer};

<div id="footer">
	[% INCLUDE lib/footer.html %]
</div>
FOOTER
    
    my $file = File::Spec->catfile(
        $base, 'root', 'lib', "wrapper_$option{layout}.html" );
    
    $helper->render_file( "wrapper_$option{layout}_html", $file, \%tmpl );
}

sub mk_layout_css {
    my ( $self, $helper, $base, $cssdir, %option ) = @_;
    
    my $file = File::Spec->catfile(
        $base, 'root', 'static', 'css', "layout_$option{layout}.css" );
    
    $helper->render_file( "layout_$option{layout}_css", $file );
}

sub mk_colour_css {
    my ( $self, $helper, $base, $cssdir, %option ) = @_;
    
    my $file = File::Spec->catfile(
        $base, 'root', 'static', 'css', "colour_$option{colour}.css" );
    
    $helper->render_file( "colour_css", $file, $colours{ $option{colour} } );
}

1;

__DATA__
__layout_single_html__
[% WRAPPER lib/wrapper_single.html %]
	Content goes here!
[% END %]

__layout_left_html__
[% WRAPPER lib/wrapper_left.html %]
	Content goes here!
[% END %]

__layout_right_html__
[% WRAPPER lib/wrapper_right.html %]
	Content goes here!
[% END %]

__layout_3column_html__
[% WRAPPER lib/wrapper_3column.html %]
	Content goes here!
[% END %]

__wrapper_single_html__
<!DOCTYPE html 
     PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<title>[% app %] - A Catalyst Application</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link href="[% colour_css %]" rel="stylesheet" type="text/css">
<link href="[% layout_css %]" rel="stylesheet" type="text/css">
</head>

<body>
[% header %]
<div id="main_content">
	Main Content goes here!
</div>
[% footer %]
</body>
</html>

__wrapper_left_html__
<!DOCTYPE html 
     PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<title>[% app %] - A Catalyst Application</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link href="[% colour_css %]" rel="stylesheet" type="text/css">
<link href="[% layout_css %]" rel="stylesheet" type="text/css">
</head>

<body>
[% header %]
<div id="main_content">
	Main Content goes here!
</div>

<div id="side_column">
	Side Column here!
</div>
[% footer %]
</body>
</html>

__wrapper_right_html__
<!DOCTYPE html 
     PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<title>[% app %] - A Catalyst Application</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link href="[% colour_css %]" rel="stylesheet" type="text/css">
<link href="[% layout_css %]" rel="stylesheet" type="text/css">
</head>

<body>
[% header %]
<div id="main_content">
	Main Content goes here!
</div>

<div id="side_column">
	Side Column here!
</div>
[% footer %]
</body>
</html>

__wrapper_3column_html__
<!DOCTYPE html 
     PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<title>[% app %] - A Catalyst Application</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link href="[% colour_css %]" rel="stylesheet" type="text/css">
<link href="[% layout_css %]" rel="stylesheet" type="text/css">
</head>

<body>
[% header %]
<div id="container">
	<div id="left_column">
		Left Column here!
	</div>

	<div id="main_content">
		Main Content goes here!
	</div>

	<div id="right_column">
		Right Column here!
	</div>
</div>
[% footer %]
</body>
</html>

__header_html__
Header goes here!

__footer_html__
Footer goes here!

__layout_single_css__

__layout_left_css__

__layout_right_css__

__layout_3column_css__

__colour_css__
body {
	background-color: [% page_bg %];
	font-family: verdana, arial, helvetica, tahoma, sans-serif;
	color: [% text_colour %];
	margin: 0;
	padding: 0;
}

#header {
	background-color: [% header_bg %];
	border: 1px solid [% header_border %];
	-moz-border-radius: 10px;
}

#main_content {
	background-color: [% main_content_bg %];
	border: 1px solid [% main_content_border %];
	-moz-border-radius: 10px;
}

#side_column {
	background-color: [% side_column_bg %];
	border: 1px solid [% side_column_border %];
	-moz-border-radius: 10px;
}

#left_column {
	background-color: [% left_column_bg %];
	border: 1px solid [% left_column_border %];
	-moz-border-radius: 10px;
}

#right_column {
	background-color: [% right_column_bg %];
	border: 1px solid [% right_column_border %];
	-moz-border-radius: 10px;
}

#footer {
	background-color: [% footer_bg %];
	border: 1px solid [% footer_border %];
	-moz-border-radius: 10px;
}
