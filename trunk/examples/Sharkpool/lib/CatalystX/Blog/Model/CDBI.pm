package CatalystX::Blog::Model::CDBI;

use strict;
use base qw/Catalyst::Model::CDBI::Sweet Catalyst::Base/;

=head1 NAME

    CatalystX::Blog::Model::Tag - An extensible and portable Tag Model

=head1 SYNOPSIS

    package MyApp::Model::CDBI;
    use base qw/CatalystX::Blog::Model::CDBI/;

    MyApp::Model::CDBI->connection('DBI:driver:database');

=head1 DESCRIPTION

=over4

=item on_select

=cut

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

=cut

1;
