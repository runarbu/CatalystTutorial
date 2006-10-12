package MiniMojoDBIC::Controller::Page;

use strict;
use warnings;
use base 'Catalyst::Controller';



sub show : Regex('^(\w+)\.html$') {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'view.tt';
    $c->forward('page');
}

sub page : Private {
    my ( $self, $c, $title ) = @_;
    $title ||= $c->req->snippets->[0] || 'Frontpage';
    my $query = { title => $title };
    $c->stash->{page} = $c->model('MiniMojoDB::Page')->find_or_create($query);
}

sub edit : Local {
    my ( $self, $c, $title ) = @_;

    $c->forward('page');
    $c->stash->{page}->body( $c->req->params->{body} )
      if $c->req->params->{body};
    my $body = $c->stash->{page}->body || 'Just type something...';
    my $html = $c->textile->process($body);

    my $base = $c->req->base;
    $html =~ s{(?<![\?\\\/\[])(\b[A-Z][a-z]+[A-Z]\w*)}
      {<a href="$base$1.html">$1</a>}g;
    $c->model('MiniMojoDB::Page')->update({title => $title, body => $body});
    $c->res->output($html);
}

=head1 NAME

MiniMojoDBIC::Controller::Root - A very nice application

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice application.

=head1 AUTHOR

Clever guy

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
