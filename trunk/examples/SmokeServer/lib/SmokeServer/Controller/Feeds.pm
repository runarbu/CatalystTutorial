package SmokeServer::Controller::Feeds;

use strict;
use warnings;
use base 'Catalyst::Controller::BindLex';

sub end : Private {
    my ( $self, $c ) = @_;

    #my $view = $c->req->param("rss") ? "RSS" : "JSON";
    my $view = "JSON";

    $c->forward( $c->view("JSON") );
}

sub tags : Local {
    my ( $self, $c ) = @_;

    my %filter;

    my @prepend;

    if ( my $prefix = $c->request->param("prefix") ) {
        if ( $c->request->param("parse_tags") ) {
	
            $prefix = (Text::Tags::Parser->new->parse_tags( $prefix || "" ))[-1];
        }

        $filter{prefix} = $prefix;
    }

    if ( my $parent = $c->request->param("parent") ) {
        $filter{parent} = $parent;
    }

    my $p = $c->request->parameters;
    $filter{shallow} = exists $p->{parent}; # parent is shallow by default, otherwise deep
    $filter{shallow} = 1 if exists $p->{shallow}; # overrides
    $filter{shallow} = 0 if exists $p->{deep};

    my $feed_data : Stashed = $c->model("SmokeDB")->get_tags( %filter );

    if ( @prepend ) {
        for ( @$feed_data ) {
	    $_ = Text::Tags::Parser->new->join_tags( @prepend, $_ );
	}
    }

    if ( $c->request->param("pairs") ) {
    	for ( @$feed_data ) {
	    $_ = [ $_ => $_ ];
	}
    }
}

sub smokes : Local {
    # TODO
}

__PACKAGE__
