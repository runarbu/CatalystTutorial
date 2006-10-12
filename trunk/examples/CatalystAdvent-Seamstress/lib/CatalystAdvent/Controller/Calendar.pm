package CatalystAdvent::Controller::Calendar;

use strict;
use warnings;

use base qw( Catalyst::Controller );

use DateTime;
use Calendar::Simple;
use File::stat;
use XML::Feed;
use Pod::Xhtml;

=head1 NAME

CatalystAdvent::Controller::Calendar - Handles calendar year/day viewing

=head1 SYNOPSIS

See L<CatalystAdvent>

=head1 DESCRIPTION

This controller provides the various methods to generate the index for
a year, display the "tip" for a given day and generate RSS feeds.

=head1 METHODS

=head2 index

Sets the year to the most recent year in the root directory. If 
this cannot be calculated, sets it to the year of the current DateTime.

Then detaches to the "year" display for the current year.


=cut

sub index : Private {
    my ( $self, $c ) = @_;
    opendir DIR, $c->path_to('root') or die "Error opening root: $!";
    my @years = sort grep { /\d{4}/ } readdir DIR;
    closedir DIR;

    my $year = pop @years || $c->stash->{now}->year;
    $c->forward( 'year', [$year] );
}

=head2 year

Displays the calendar for any given year

=cut

sub year : Regex('^(\d{4})$') {
    my ( $self, $c, $year ) = @_;
    $year ||= $c->req->snippets->[0];
    $c->res->redirect( $c->uri_for('/') )
        unless ( -e $c->path_to( 'root', $year ) );
    $c->stash->{year}     = $year;
    $c->stash->{calendar} = calendar( 12, $year );
    use Data::Dumper; warn "CAL: ", Dumper($c->stash->{calendar}) ;
#    $c->stash->{template} = 'year.tt';
    $c->stash->{LOOM} = 'root::year';
}

=head2 day

Displays the tip of the day. Uses Pod::Xhtml to do the conversion from
pod to html.

=cut

sub day : Regex('^(\d{4})/(\d\d?)$') {
    my ( $self, $c, $year, $day ) = @_;
    $year ||= $c->req->snippets->[0];
    $day  ||= $c->req->snippets->[1];

    $c->detach( 'year', [$year] )
        unless ( -e ( my $file = $c->path_to( 'root', $year, "$day.pod" ) ) );
    $c->stash->{calendar} = calendar( 12, $year );
    $c->stash->{year}     = $year;
    $c->stash->{day}      = $day;
#    $c->stash->{template} = 'day.tt';
    $c->stash->{LOOM}     = 'root::day';

    # cache the generated XHTML file so we're not parsing it on every request
    my $mtime      = ( stat $file )->mtime;
    my $cached_pod = $c->cache->get("$file $mtime");
    if ( !$cached_pod ) {
        my $parser = Pod::Xhtml->new(
            StringMode   => 1,
            FragmentOnly => 1,
            MakeIndex    => 0,
            TopLinks     => 0
        );
        $parser->parse_from_file("$file");
        $cached_pod = $parser->asString;
        $c->cache->set( "$file $mtime", $cached_pod, '12h' );
    }

    $c->stash->{pod} = HTML::TreeBuilder->new_from_content($cached_pod);
}

=head2 rss

Generates an rss feed of tips for the given year.

=cut

sub rss : Global {
    my ( $self, $c, $year ) = @_;
    my $feed = XML::Feed->new('RSS');
    $year ||= $c->stash->{now}->year;
    $feed->title( $c->config->{name} . ' RSS Feed' );
    $feed->link( $c->req->base );
    $feed->description('Catalyst advent calendar');
    $year ||= $c->req->snippets->[0];
    $c->res->redirect( $c->uri_for('/') )
        unless ( -e $c->path_to( 'root', $year ) );
    $c->stash->{year} = $year;
    my ( $day, $entries ) = ( 24, 0 );
    my $feed_mtime = 0;

    while ( $day > 0 && $entries < 5 ) {
        if ( -e ( my $file = $c->path_to( 'root', $year, "$day.pod" ) ) ) {
            my $stat = stat $file;
            my $mtime = $stat->mtime;
            my $ctime = $stat->ctime;
            $feed_mtime = $mtime if $mtime > $feed_mtime;
            my $entry = XML::Feed::Entry->new('RSS');
            $entry->title("Calendar entry for day $day.");
            $entry->link( $c->uri_for("/$year/$day") );
            $entry->issued( DateTime->from_epoch( epoch   => $ctime ) );
            $entry->modified( DateTime->from_epoch( epoch => $mtime ) );

            $feed->add_entry($entry);
            $entries++;
        }
        $day--;
    }
    $feed->modified( DateTime->from_epoch( epoch => $feed_mtime ) );
    $c->res->body( $feed->as_xml );
    $c->res->content_type('application/rss+xml');
}

=head1 AUTHORS

=head2 Seamstress rework: Terrence Brannon

=head2 Original by...

Brian Cassidy, <bricas@cpan.org>

Sebastian Riedel, <sri@cpan.org>

Andy Grundman, <andy@hybridized.org>

Marcus Ramberg, <mramberg@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
