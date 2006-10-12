package IM::Controller::Messages;

use strict;
use warnings;
use base 'Catalyst::Controller::BindLex';

=head1 NAME

IM::Controller::Messages - Catalyst Controller

=head1 SYNOPSIS

See L<IM>

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    my $rs = $c->model("Message")->get_messages( rows=>30 );

    my @messages : Stashed = $rs->all;

    my $template : Stashed = "messages.tt";
}

sub history : Local {
    my ( $self, $c ) = @_;

    my $page = $c->req->params->{page} || 1;
    my $rs = $c->model("Message")->search( {}, { order_by=>'posted', rows=>30, page=>$page } );

    my @messages : Stashed = $rs->all;
    my $pager    : Stashed = $rs->pager;

    my $template : Stashed = "history.tt";
}

sub from : Local {
    my ( $self, $c, $last ) = @_;

    $last ||= 0;

    my @messages : Stashed = $c->model("Message")->get_messages_from($last)->all;

    my $template : Stashed = "message_box.tt";
}

sub send : Local {
    my ( $self, $c, $from ) = @_;

    if ( $c->req->params->{content} ) {
        $c->model("Message")->create(
            {
                author  => $c->session->{author},
                content => $c->req->param("content"),
                posted  => time(),
            }
        );
    }

    if ( $c->request->header('X-Requested-With') eq 'XMLHttpRequest' ) {
        if ($from) {
            $c->forward("from");
        } else {
            $c->res->body(" ");
        }
    } else {
        $c->forward("index");
    }
}

=head1 AUTHOR

יובל קוג'מן

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
