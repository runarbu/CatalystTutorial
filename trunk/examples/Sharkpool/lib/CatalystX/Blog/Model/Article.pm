package CatalystX::Blog::Model::Article;

use strict;
use base 'CatalystX::Blog::Model::CDBI';

use DateTime;
use DBI;
use Text::Unaccent ();

__PACKAGE__->table('article');
__PACKAGE__->columns( Primary => qw/article_id/ );
__PACKAGE__->columns(
    Essential => qw/title summary author uri publication_date/ );
__PACKAGE__->columns(
    Others => qw/content creation_date modification_date expiration_date/ );

__PACKAGE__->sequence('uuid');

__PACKAGE__->data_type(
    article_id        => DBI::SQL_CHAR,
    title             => DBI::SQL_VARCHAR,
    summary           => DBI::SQL_VARCHAR,
    content           => DBI::SQL_LONGVARCHAR,
    author            => DBI::SQL_VARCHAR,
    uri               => DBI::SQL_VARCHAR,
    creation_date     => DBI::SQL_INTEGER,       # UTC epoch
    modification_date => DBI::SQL_INTEGER,       # UTC epoch
    publication_date  => DBI::SQL_INTEGER,       # UTC epoch
    expiration_date   => DBI::SQL_INTEGER,       # UTC epoch
);

__PACKAGE__->has_a(
    creation_date => 'DateTime',
    inflate       => sub { DateTime->from_epoch( epoch => shift ) },
    deflate => sub { shift->epoch }
);

__PACKAGE__->has_a(
    modification_date => 'DateTime',
    inflate           => sub { DateTime->from_epoch( epoch => shift ) },
    deflate => sub { shift->epoch }
);

__PACKAGE__->has_a(
    publication_date => 'DateTime',
    inflate          => sub { DateTime->from_epoch( epoch => shift ) },
    deflate => sub { shift->epoch }
);

__PACKAGE__->has_a(
    expiration_date => 'DateTime',
    inflate         => sub { DateTime->from_epoch( epoch => shift ) },
    deflate => sub { shift->epoch }
);

__PACKAGE__->add_trigger(
    before_create => \&on_create,
    before_update => \&on_update,
    select        => \&CatalystX::Blog::Model::CDBI::on_select
);

=head1 NAME

    CatalystX::Blog::Model::Article - An extensible and portable Article Model

=head1 SYNOPSIS

    package MyApp::Model::CDBI;
    use base qw/CatalystX::Blog::Model::CDBI/;

    MyApp::Model::CDBI->connection('DBI:driver:database');


    package MyApp::Model::Article;
    use base qw/MyApp::Model::CDBI CatalystX::Blog::Model::Article/;


    package MyApp::Controller::Article;

    my $article = MyApp::Model::Article->create({
        author  => 'Catalyst Team',
        title   => 'Catalyst::Model::CDBI::Article',
        summary => 'An extensible and portable Article Model',
        content => '...'
    });

    $article->publication_date( DateTime->now );
    $article->expiration_date( DateTime->now->add( months => 1 ) );
    $article->update;

    printf( "Uri: http://www.site.com/%s\n", $article->uri );
    printf( "Published on: %s", $article->publication_date->ymd );


    my $criteria = {
        expiration_date  => [ \"IS NULL", { '>', DateTime->now } ],
        publication_date => {
            -between => [
                DateTime->new( year => 2004 ),
                DateTime->new( year => 2005 )
            ]
        }
    };

    printf( "Found %d published articles between 2004 and 2005",
        MyApp::Model::Article->count($query) );

    ( $articles, $page ) =
        MyApp::Model::Article->page( $criteria, { rows => 10 } );

    printf( "Results %d - %d of %d Found\n",
        $page->first, $page->last, $page->total_entries );


=head1 DESCRIPTION

=over4

=item on_create

=cut

sub on_create {
    my $self = shift;

    $self->creation_date( DateTime->now );

    if ( $self->publication_date ) {
        $self->uri(
            $self->create_uri( $self->publication_date, $self->title ) );
    }
}

=item on_update

=cut

sub on_update {
    my $self = shift;

    my ( @changed, %columns );

    @changed = $self->is_changed or return;

    $self->modification_date( DateTime->now );

    @columns{@changed} = (1) x @changed;

    if ( $columns{title} || $columns{publication_date} ) {

        my $uri = undef;

        if ( $self->publication_date ) {
            $uri = $self->create_uri( $self->publication_date, $self->title );
        }

        $self->uri($uri);
    }
}

=item is_published

=cut

sub is_published {
    my $self = shift;

    return 0 unless $self->publication_date;
    return 0 unless $self->publication_date->epoch < DateTime->now->epoch;
    return 0 if $self->is_expired;
    return 1;
}

=item is_expired

=cut

sub is_expired {
    my $self = shift;

    return 0 unless $self->expiration_date;
    return 0 unless $self->expiration_date->epoch < DateTime->now->epoch;
    return 1;
}

=item create_uri

=cut

sub create_uri {
    my ( $self, $date, $title ) = @_;

    return unless $date;
    return unless $title;

    unless ( UNIVERSAL::isa( $date, 'DateTime' ) ) {
        return $self->_croak("create_uri needs a DateTime object");
    }

    $title = Text::Unaccent::unac_string( 'UTF-8', $title );
    $title =~ s/\W+/_/g;

    return sprintf( '%04d/%02d/%02d/%s',
        $date->year, $date->month, $date->day, lc($title) );
}

=item retrieve_published

=cut

sub retrieve_published {
    my $self  = shift;
    my $class = ref($self) || $self;

    if ( my ($article) = $class->retrieve(@_) ) {

        if ( defined($article) && $article->is_published ) {
            return $article;
        }
    }

    return undef;
}

=item next_published

=cut

sub next_published {
    my $self  = shift;
    my $class = ref($self) || $self;

    my $criteria = {
        expiration_date => [ \"IS NULL", { '>', DateTime->now } ],
        publication_date => { '>', $self->publication_date }
    };

    my $attributes = {
        order_by => 'publication_date ASC',
        rows     => 1
    };

    if ( $class->count($criteria) > 0 ) {
        my ($article) = $class->search( $criteria, $attributes );
        return $article;
    }

    return undef;
}

=item previous_published

=cut

sub previous_published {
    my $self  = shift;
    my $class = ref($self) || $self;

    my $criteria = {
        expiration_date => [ \"IS NULL", { '>', DateTime->now } ],
        publication_date => { '<', $self->publication_date }
    };

    my $attributes = {
        order_by => 'publication_date DESC',
        rows     => 1
    };

    if ( $class->count($criteria) > 0 ) {
        my ($article) = $class->search( $criteria, $attributes );
        return $article;
    }

    return undef;
}

=back

=head1 AUTHOR

Christian Hansen <ch@ngmedia.com>

=head1 THANKS TO

Danijel Milicevic, Jesse Sheidlower, Marcus Ramberg, Sebastian Riedel,
Viljo Marrandi

=head1 SUPPORT

#catalyst on L<irc://irc.perl.org>

L<http://lists.rawmode.org/mailman/listinfo/catalyst>

L<http://lists.rawmode.org/mailman/listinfo/catalyst-dev>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Catalyst::Model::CDBI::Sweet>

L<DateTime>

=cut

1;
