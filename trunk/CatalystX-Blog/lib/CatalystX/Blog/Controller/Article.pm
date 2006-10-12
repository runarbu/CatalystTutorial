package CatalystX::Blog::Controller::Article;

use strict;
use base 'Catalyst::Base';

use DateTime;

sub end : Private {
    my ( $self, $c ) = @_;

    return 1 if $c->response->status =~ /^3\d\d$/;
    return 1 if $c->response->body;

    unless ( $c->response->content_type ) {
        $c->response->content_type('text/html; charset=utf-8');
    }

    $c->forward('CatalystX::Blog::View::TT');
}

sub default : Private {
    my ( $self, $c ) = @_;

    $c->stash->{archive_start} = DateTime->now->subtract( months => 6 );
    $c->stash->{archive_end}   = DateTime->now;

    $c->forward('archive');
    
    $c->stash->{template} = 'blog/article/frontpage';
}

sub archive : Private {
    my ( $self, $c ) = @_;

    my $criteria = {
        expiration_date  => [ \"IS NULL", { '>', DateTime->now } ],
        publication_date => {
           '<'       => DateTime->now,
            -between => [
                $c->stash->{archive_start},
                $c->stash->{archive_end}
            ]
        }
    };

    my $attributes = {
        order_by => 'publication_date DESC',
        page     => $c->request->param('p') || 1,
        rows     => 20
    };

    my ( $page, $iterator ) = CatalystX::Blog::Model::Article->page( $criteria, $attributes );

    $c->stash->{pager}    = $page;
    $c->stash->{articles} = $iterator;
    $c->stash->{template} = 'blog/article/archive';
}

sub archive_day : Regexp('^article/(\d{4})/(\d{2})/(\d{2})$') {
    my ( $self, $c ) = @_;

    my $datetime = DateTime->new(
        year  => $c->request->snippets->[0],
        month => $c->request->snippets->[1],
        day   => $c->request->snippets->[2]
    );

    $c->stash->{archive_start} = $datetime;
    $c->stash->{archive_end}   = $datetime->clone->add( days => 1 );

    $c->forward('archive');
}

sub archive_month : Regexp('^article/(\d{4})/(\d{2})$') {
    my ( $self, $c ) = @_;

    my $datetime = DateTime->new(
        year  => $c->request->snippets->[0],
        month => $c->request->snippets->[1]
    );

    $c->stash->{archive_start} = $datetime;
    $c->stash->{archive_end}   = $datetime->clone->add( months => 1 );

    $c->forward('archive');
}

sub archive_year : Regexp('^article/(\d{4})$') {
    my ( $self, $c ) = @_;

    my $datetime = DateTime->new(
        year  => $c->request->snippets->[0]
    );

    $c->stash->{archive_start} = $datetime;
    $c->stash->{archive_end}   = $datetime->clone->add( years => 1 );

    $c->forward('archive');
}

sub search : Path('search') {
    my ( $self, $c ) = @_;
    
    $c->stash->{template} = 'blog/article/search';
}

sub search_ajax : Path('search/ajax') {
    my ( $self, $c ) = @_;
}

sub view : Regexp('^article/(\d{4})/(\d{2})/(\d{2})/(\w+)$') {
    my ( $self, $c ) = @_;

    my $uri     = join( '/', @{ $c->request->snippets } );
    my $article = CatalystX::Blog::Model::Article->retrieve_published( uri => $uri );

    unless ( defined $article ) {
       die("404 Not Found");
    }

    $c->stash->{article}  = $article;
    $c->stash->{template} = 'blog/article/view';
}

1;
