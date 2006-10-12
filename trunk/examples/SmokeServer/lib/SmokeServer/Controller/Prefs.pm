package SmokeServer::Controller::Prefs;

use strict;
use warnings;
use base qw/
	Catalyst::Controller::BindLex
/;

use Text::Tags::Parser ();
sub parse_tags { Text::Tags::Parser->new->parse_tags( @_ ) }
sub join_tags { Text::Tags::Parser->new->join_tags( @_ ) }

=head1 NAME

SmokeServer::Controller::Prefs - Catalyst Controller

=head1 SYNOPSIS

See L<SmokeServer>

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub begin : Private {
	my ( $self, $c ) = @_;

	my $w = $c->widget("prefs");

	$w->indicator( sub { scalar keys %{ $c->req->params } } );

	$w->action( $c->uri_for("save") );
	$w->method( "post" );

	my @fields = (
		default_tag => "Filter by tag",
		default_group_tags => "Group by tags",
		ignored_tags_cloud => "Filter from tag cloud",
	);

	while ( my ( $field, $label ) = splice(@fields, 0, 2) ) {
		$w->element( Textfield => $field )->label( "$label:" )->value(
			join_tags( @{ $c->session->{$field} || [] } ),
		);
	}

	$w->element( Submit => "save" )->value("Save");
}

sub save : Local {
	my ( $self, $c ) = @_;

	my $res = $c->widget_result("prefs");

	if ( my @valid = $res->valid ) {
		foreach my $valid_key ( @valid ) {
			$c->log->debug("saving $valid_key");
			$c->session->{$valid_key} = [ parse_tags( $res->param( $valid_key ) ) ];
		}
	} else {
		die Data::Dumper::Dumper("invalid widget params", $res);
	}

	$c->forward("index");
}

sub index : Private {
	my ( $self, $c ) = @_;
	my $template : Stashed = "prefs.tt";
}

=head1 AUTHOR

יובל  קוג'מן

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
