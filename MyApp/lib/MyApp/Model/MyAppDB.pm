package MyApp::Model::MyAppDB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

my $dsn = $ENV{MYAPP_DSN} ||= 'dbi:SQLite:myapp.db';
__PACKAGE__->config(
    schema_class => 'MyApp::Schema::MyAppDB',
    connect_info => [
        $dsn,
        
    ],
);

=head1 NAME

MyApp::Model::MyAppDB - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<MyApp>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<MyApp::Schema::MyAppDB>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
