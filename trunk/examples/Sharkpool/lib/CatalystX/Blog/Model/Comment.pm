package CatalystX::Blog::Model::Comment;

use strict;
use base 'CatalystX::Blog::Model::CDBI';

use DateTime;
use DBI;

__PACKAGE__->table('comment');
__PACKAGE__->columns( Primary => qw/comment_id/ );
__PACKAGE__->columns(
    Essential => qw/article title author url email content creation_date/ );

__PACKAGE__->sequence('uuid');

__PACKAGE__->data_type(
    comment_id    => DBI::SQL_CHAR,
    article       => DBI::SQL_CHAR,
    title         => DBI::SQL_VARCHAR,
    author        => DBI::SQL_VARCHAR,
    url           => DBI::SQL_VARCHAR,
    email         => DBI::SQL_VARCHAR,
    content       => DBI::SQL_LONGVARCHAR,
    creation_date => DBI::SQL_INTEGER        # UTC epoch
);

__PACKAGE__->has_a(
    creation_date => 'DateTime',
    inflate       => sub { DateTime->from_epoch( epoch => shift ) },
    deflate => sub { shift->epoch }
);

__PACKAGE__->add_trigger(
    before_create => \&on_create,
    select        => \&CatalystX::Blog::Model::CDBI::on_select
);

=head1 NAME

    CatalystX::Blog::Model::Comment - An extensible and portable Comment Model

=head1 SYNOPSIS

    package MyApp::Model::CDBI;
    use base qw/CatalystX::Blog::Model::CDBI/;

    MyApp::Model::CDBI->connection('DBI:driver:database');


    package MyApp::Model::Comment;
    use base qw/MyApp::Model::CDBI CatalystX::Blog::Model::Comment/;


=head1 DESCRIPTION

=cut

sub on_create {
    my $self = shift;
    $self->creation_date( DateTime->now );
}

sub on_select {
    my $self  = shift;
    my $class = ref($self) || $self;

    my $datatypes = $class->__data_type or return;

    while ( my ( $column, $type ) = each %{$datatypes} ) {

        next
          unless $type == DBI::SQL_CHAR
          || $type == DBI::SQL_VARCHAR
          || $type == DBI::SQL_LONGVARCHAR;

        next unless defined( $self->{$column} );

        next if ref( $self->{$column} );

        next if utf8::is_utf8( $self->{$column} );

        utf8::decode( $self->{$column} );
    }
}

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
