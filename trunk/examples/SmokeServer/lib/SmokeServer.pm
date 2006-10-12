package SmokeServer;

use strict;
use warnings;

use lib grep { m{Catalyst/|HTML|DBIC|Fun|Bind|Session} } glob "/home/nothingmuch/catalyst/*/lib";

use Catalyst qw/
    Static::Simple
    Cache::FastMmap

    Session::Defaults
	Session
	Session::Store::FastMmap
	Session::State::Cookie

	HTML::Widget
/;

our $VERSION = '0.01';

__PACKAGE__->config( name => __PACKAGE__ );
__PACKAGE__->config( cache => { storage => __PACKAGE__->path_to(qw/tmp matrix_cache/)->stringify } );
__PACKAGE__->config( static => { ignore_extensions => [ qw/tt/ ] } );

__PACKAGE__->config( session => {
	expires => 60 * 60 * 24 * 365 * 10, # ten years
	verify_address => 0,	
	storage => __PACKAGE__->path_to(qw/tmp session/)->stringify,
    defaults => {
        ignored_tags_cloud => [qw/version/],
        default_group_tags => [qw/module version/],
    },
});

__PACKAGE__->config( "View::JSON" => {
    expose_stash => "feed_data",
});

__PACKAGE__->setup;

=head1 NAME

SmokeServer - Catalyst based application

=head1 SYNOPSIS

    script/smokeserver_server.pl

=head1 DESCRIPTION

Catalyst based application.

=head1 SEE ALSO

L<SmokeServer::Controller::Root>, L<Catalyst>

=head1 AUTHOR

יובל קוג'מן

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
