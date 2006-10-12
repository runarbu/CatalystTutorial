package SmokeServer::Controller::Smoke;

use strict;
use warnings;
use base qw/
    Catalyst::Controller::BindLex
    Catalyst::Controller
/;

use Text::Tags::Parser ();
use Test::TAP::HTMLMatrix ();
use Test::TAP::Model::Visual ();
use Data::Serializer ();
use HTML::TagCloud ();
use SmokeDB::SmokeGrouper;

__PACKAGE__->config( namespace => "" );

=head1 NAME

SmokeServer::Controller::Smoke - Catalyst Controller

=head1 SYNOPSIS

See L<SmokeServer>

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub end : Private {
    my ( $self, $c ) = @_;

    unless ( $c->res->body ) {
        my $view = $c->view("TT");
        $view->generate_functions( [ $c => qw/uri_for/ ] );
        $c->forward( $view );
    }
}

sub index : Private {
    my ( $self, $c ) = @_;
    my $template : Stashed = "list.tt";
    $c->forward("list");
}

sub list : Local {
    my ( $self, $c, @args ) = @_;

    my $tag : Stashed = $c->request->param("tag");
    $tag = shift @args if @args;

    my @group_tags : Stashed;
    if ( exists $c->req->params->{group_tags} ) {
        @group_tags = Text::Tags::Parser->new->parse_tags( $c->req->param("group_tags") || "" );
    } else {
        my @default_group_tags : Session;
        @group_tags = @default_group_tags;
    }

    # TODO filter by multiple tags...
    #  intersection as well as union in SQL
    #  filtered_tag+$tagname in the tag URIs
    #$tag_string =~ tr/+/ /;
    #my $tags = Text::Folksonomies->new->parse( $tag_string );

    my $smoke_rs : Stashed = $c->model("SmokeDB")->get_smokes(
        tag      => $tag,
    );

    my $grouper = SmokeDB::SmokeGrouper->new(@group_tags);
    my $smokes : Stashed = $grouper->group( $smoke_rs );

    $c->forward("generate_tag_cloud", [ $smoke_rs, $tag ]);
}

sub generate_tag_cloud : Private {
    my ( $self, $c, $tag_filter ) = @_;
    
    my $smoke_rs : Stashed;
    my $tag_rs = $smoke_rs->related_resultset("smoke_tags")->related_resultset("tag");

    #### ATHIOUJDHSTKALJHT ALKJT ! FUCK XXX TODO FIXME
    $tag_rs->{cond}{"tag_2.name"} = delete $tag_rs->{cond}{"tag.name"};


    # filter ignored tags
    my $ignored_tags = $c->session->{ignored_tags_cloud};
    $tag_rs = $tag_rs->search({
        'tag.name' => [ -and => map { { -not_like => "$_%" } } @$ignored_tags ]
    }) if @$ignored_tags;

    # all hail DBIC
    my $tags = $tag_rs->search(undef, {
        select => [
            "tag.name",
            { count => "tag.id" },
        ],
        as => [ "name", "tag_count" ],
        group_by => [ "tag.id" ],
    });

    my $cloud : Stashed = HTML::TagCloud->new;

    foreach my $tag ( $tags->all ) {
        my $name = $tag->name;
        no warnings "uninitialized";
        my $uri = $c->uri_for( list => ( $name eq $tag_filter ? () : $name ) );
        my $count = $tag->get_column("tag_count");

        $cloud->add( $name, $uri, $count );
    }
}

sub detail : Local {
    my ( $self, $c, $id ) = @_;
    $c->forward( matrix => [ $c->model("SmokeDB")->get_smokes( id => $id )->all ]);
}

sub compare : Local {
    my ( $self, $c ) = @_;
    my @ids = $c->req->param("smoke");
    $c->forward( matrix => [ $c->model("SmokeDB")->get_smokes(id => \@ids)->all ] );
}

sub matrix : Private {
    my ( $self, $c, @smokes ) = @_;

    @smokes = grep { $_ } @smokes;

    if ( @smokes ) {
        my $cache_key = "htmlmatrix:" . join(",", sort map { $_->id } @smokes );

        # yucky ref hack is due to Cache::FastMmap limitations
        $c->res->content_type("text/html; charset=utf-8");
        $c->res->body( ${  $c->cache->get( $cache_key ) || do {
            $c->log->debug("cache miss for $cache_key") if $c->debug;
            my @vis = map { Test::TAP::Model::Visual->new_with_struct( $_->model->structure ) } @smokes;
            my $vis = Test::TAP::HTMLMatrix->new( @vis );
	    $vis->has_inline_css(1);
	    my $output = $vis->detail_html;
            $c->cache->set( $cache_key, \$output );
            \$output;
        }});
    } else {
        $c->res->body("no such smoke reports");
    }
}

sub submit : Local {
    my ( $self, $c ) = @_;

    $c->detach("upload") if $c->req->param("smoke_report");
}

sub upload : Local {
    my ( $self, $c ) = @_;

    # FIXME this is really unsafe
    # the serializer could be Data::Dumper
    if ( my $smoke = eval { Data::Serializer->new->deserialize( $c->req->param("smoke_report") ) } ) {
        $c->model("SmokeDB")->add_smoke( $smoke );
        $c->res->body("OK");
    } else {
        $c->res->status(500);
        $c->res->body("bad dog no no");
    }
}

=head1 AUTHOR

יובל קוג'מן

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
