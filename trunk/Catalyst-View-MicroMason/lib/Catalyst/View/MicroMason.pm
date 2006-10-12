package Catalyst::View::MicroMason;

use strict;
use base qw/Catalyst::View Class::Accessor/;
use Text::MicroMason;
use NEXT;

our $VERSION = '0.04';

__PACKAGE__->mk_accessors(qw(template Mixins template_root));

=head1 NAME

Catalyst::View::MicroMason - MicroMason View Class

=head1 SYNOPSIS

    # use the helper
    script/create.pl view MicroMason MicroMason

    # lib/MyApp/View/MicroMason.pm
    package MyApp::View::MicroMason;

    use base 'Catalyst::View::MicroMason';

    __PACKAGE__->config(
        # -Filters      : to use |h and |u
        # -ExecuteCache : to cache template output
        # -CompileCache : to cache the templates
        Mixins        => [qw( -Filters -CompileCache )], 
        template_root => '/path/to/comp_root'
    );

    1;
    
    # In an 'end' action
    $c->forward('MyApp::View::MicroMason');

=head1 DESCRIPTION

Want to use a MicroMason component in your views? No problem!
Catalyst::View::MicroMason comes to the rescue.

=head1 CAVEATS

You have to define C<template_root>.  If C<template_root> is not directly
defined within C<config>, the value comes from C<config->{root}>. If you don't
define it at all, MicroMason is going to use the root of your system.

=head1 METHODS

=cut

sub new {
    my ($self, $c) = @_;
    shift;
    
    $self = $self->NEXT::new(@_);
    my $root = $self->template_root || $c->config->{root};

    my @Mixins  = @{ $self->Mixins || [] };
    push @Mixins, qw(-TemplateDir -AllowGlobals); 
    $self->template(Text::MicroMason->new(@Mixins, 
					  template_root => $root,
					  %$self
					 )
		   );
    
    return $self;
}

=head2 process

Renders the component specified in $c->stash->{template} or by the
value $c->action (if $c->stash->{template} is undefined).

MicroMason global variables C<$base>, C<$c> and c<$name> are
automatically set to the base, context and name of the app,
respectively.

An exception is thrown if processing fails, otherwise the output is stored
in C<< $c->response->body >>.

=cut

sub process {
    my ( $self, $c ) = @_;
    
    $c->response->headers->content_type('text/html;charset=utf8')
      unless $c->response->content_type;
    
    $c->res->body( $self->render($c) );
    return 1;
}

=head2 render($c, [$template])

Renders the given template and returns output.  Throws an exception on
error.  If $template is not defined, the value of "template" from the
stash is used instead.

=cut

sub render {
    my ($self, $c, $component_path) = @_;
    $component_path ||= $c->stash->{template} || $c->action;
    
    # Set the URL base, context and name of the app as global Mason vars
    # $base, $c and $name
    $self->template->set_globals(
				 '$base' => $c->req->base,
				 '$c'    => $c,
				 '$name' => $c->config->{name}
				);
    
    # render it
    my $output = eval {
        $self->template->execute(file => $component_path, %{$c->stash});
    };
    
    # errors?
    if (my $error = $@ ) {
        chomp $error;
        $error =
          qq/Couldn't render component "$component_path" - error was "$error"/;
        $c->error($error);
    }
    
    return $output;
}


=head1 SEE ALSO

L<Catalyst>, L<Text::MicroMason>, L<Catalyst::View::Mason>

=head1 AUTHOR

Jonas Alves C<jgda@cpan.org>

=head1 MAINTAINER

The Catalyst Core Team L<http://www.catalystframework.org>

Jonathan Rockway C<< <jrockway@cpan.org> >>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
