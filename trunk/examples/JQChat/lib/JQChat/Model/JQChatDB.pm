package JQChat::Model::JQChatDB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'JQChatDB',
    connect_info => [
        'dbi:SQLite:db/chat.db',
        
    ],
);

=head1 NAME

JQChat::Model::JQChatDB - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<JQChat>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<JQChatDB>

=head1 AUTHOR

Kieren Diment

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
