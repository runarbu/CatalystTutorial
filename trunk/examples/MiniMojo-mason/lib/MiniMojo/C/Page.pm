package MiniMojo::C::Page;

use strict;
use base 'Catalyst::Base';

=head1 NAME

MiniMojo::C::Page - Catalyst component

=head1 SYNOPSIS

See L<MiniMojo>

=head1 DESCRIPTION

Catalyst component.

=head1 METHODS

=over 4

=item default

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->res->output('Congratulations, MiniMojo::C::Page is on Catalyst!');
}

sub show : Regex('^(\w+)\.html$') {
    my ( $self, $c ) = @_;
#    $c->stash->{template} = 'view.tt';
    $c->stash->{template} = 'wiki.mhtml';
    $c->forward('page');
}

sub page : Private {
    my ( $self, $c, $title ) = @_;
    $title ||= $c->req->snippets->[0];

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
    $html    =~ s{(?<![\?\\\/\[])(\b[A-Z][a-z]+[A-Z]\w*)}
                 {<a href="$base$1.html">$1</a>}g;

    $c->res->output($html);
}

=back

=head1 AUTHOR

Jason Gessner

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;
