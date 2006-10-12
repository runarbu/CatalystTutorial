package MiniMojo::C::Page;

use strict;
use base 'Catalyst::Base';

sub page : Private {
    my ( $self, $c, $title ) = @_;
    $title ||= $c->req->snippets->[0] || 'Frontpage';
    my $query = { title => $title };
    $c->stash->{page} = MiniMojo::M::CDBI::Page->find_or_create($query);
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

    $c->res->output($html);
}

sub show : Regex('^(\w+).html$') {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'view.tt';
    $c->forward('page');
}

=head1 NAME

MiniMojo::C::Page - A Component

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice component.

=head1 AUTHOR

Clever guy

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
