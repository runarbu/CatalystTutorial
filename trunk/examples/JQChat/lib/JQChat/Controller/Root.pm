package JQChat::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';
use HTML::Sanitizer;
my $scrub = HTML::Sanitizer->new;
$scrub->permit_only(
    qw/ strong em /,
    a => {
        href => qr/^(?:http|ftp):/,
        title => 1,
    },
    img => {
        src => qr/^(?:http|ftp):/,
        alt => 1,
    },
    b => HTML::Element->new('strong'),
);
use DateTime;


__PACKAGE__->config->{namespace} = '';

=head1 NAME

JQChat::Controller::Root - Root Controller for JQChat

=head1 DESCRIPTION

Simple Jquery web based ajax chat thingy.

=head1 METHODS

=cut

=head2 index

The chat page

=cut

sub index : Private {
    my ($self, $c) = @_;
    $c->stash->{template} = 'chat.tt';
}

=head2 default

Returns a 404 not found response and body

=cut

sub default : Private {
    my ($self, $c) = @_;
    $c->res->status(404);
    $c->res->body("404 Not found");
}

=head2 default

The ajax bit

=cut

sub chat : Local {
    my ( $self, $c ) = @_;
    my %data;
    $data{message} = $scrub->filter_html_fragment( $c->req->param('message')) ;
    if ($data{message}) {
        $data{name} = $scrub->filter_html_fragment($c->req->param('name'));
        my $dt = DateTime->now;
        $data{time} = $dt->hour . ":" . $dt->minute;
        # because this app has only one model, we don't need to
        # specify which model to use to $c->model.  We'd call
        # $c->Model('JQChatDB::Chat') is the right name to use though.
        my $rs = $c->model->create(\%data);
        # this is a stupid way to do this but I'm not prepared to rtfm
        # to work out the correct way atm.
        # Anyway, delete all but the most recent 100 posts
        my $i = 0;
        my $recs = $c->model->search({});

        while (my $rec = $recs->next) {
            $i++;
            $rec->delete if $i > 100;
            $rec->update;
        }
    }
    # If no message sent, just show the chat entries.
    else {
        my $rs = $c->model->search({}, {order_by => 'id DESC'});
        my $response = '';
        while (my $msg = $rs->next) {
            $response = $response
                . '<em>'. $msg->time .'</em> '
                . $msg->name.': <strong>'
                . $msg->message.'</strong><br />';
        }
        $c->res->body($response);
    }
}


=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Kieren Diment

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
