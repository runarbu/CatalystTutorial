package CatalystX::Blog::Model::Tag;

use strict;
use base 'CatalystX::Blog::Model::CDBI';

use DateTime;
use DBI;

__PACKAGE__->table('tag');
__PACKAGE__->columns( Primary   => qw/tag_id/ );
__PACKAGE__->columns( Essential => qw/article name/ );

__PACKAGE__->sequence('uuid');

__PACKAGE__->data_type(
    tag_id  => DBI::SQL_CHAR,
    article => DBI::SQL_CHAR,
    name    => DBI::SQL_VARCHAR
);

__PACKAGE__->add_trigger( select => \&Catalyst::Blog::Model::CDBI::on_select );

=head1 NAME

    CatalystX::Blog::Model::Tag - An extensible and portable Tag Model

=head1 SYNOPSIS

    package MyApp::Model::CDBI;
    use base qw/CatalystX::Blog::Model::CDBI/;

    MyApp::Model::CDBI->connection('DBI:driver:database');


    package MyApp::Model::Tag;
    use base qw[MyApp::Model::CDBI CatalystX::Blog::Model::Tag];


    package MyApp::Controller::Tag;

    my $tag = MyApp::Model::Tag->create({
        article => MyApp::Model::Article->new(...),
        name => 'sometag'
    });

    $tag->update;


=head1 DESCRIPTION

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
