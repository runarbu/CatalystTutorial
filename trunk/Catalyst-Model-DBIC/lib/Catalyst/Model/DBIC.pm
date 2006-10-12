package Catalyst::Model::DBIC;

use strict;
use base 'Catalyst::Model';
use NEXT;
use DBIx::Class::Loader;

our $VERSION = '0.14';

__PACKAGE__->mk_accessors('loader');

=head1 NAME

Catalyst::Model::DBIC - (DEPRECATED) DBIC Model Class

=head1 SYNOPSIS

    # use the helper
    create model DBIC DBIC dsn user password

    # lib/MyApp/Model/DBIC.pm
    package MyApp::Model::DBIC;

    use base 'Catalyst::Model::DBIC';

    __PACKAGE__->config(
        dsn           => 'dbi:Pg:dbname=myapp',
        password      => '',
        user          => 'postgres',
        options       => { AutoCommit => 1 },
        relationships => 1
    );

    1;

    $c->model('DBIC')->table('foo')->search(...);

    MyApp::Model::DBIC::Table->search(...);

=head1 DEPRECATION NOTICE

This module has been deprecated in favor of the schema-based
L<Catalyst::Model::DBIC::Schema>. This module should only be considered
as a temporary measure if you are porting from L<Catalyst::Model::CDBI>.

=head1 DESCRIPTION

This is the C<DBIx::Class> model class. It's built on top of 
C<DBIx::Class::Loader>.

=head1 METHODS

=over 4

=item new

Initializes DBIx::Class::Loader and loads classes using the class config.

=cut

sub new {
    my ( $self, $c, $config ) = @_;
    $self = $self->NEXT::new($c, $config);
    $self->{namespace}               ||= ref $self;
    $self->{additional_base_classes} ||= ();
    eval { $self->loader( DBIx::Class::Loader->new(%$self) ) };
    if ($@) { $c->log->debug(qq/Couldn't load tables "$@"/) if $c->debug }
    else {
        $c->log->debug(
            'Loaded tables "' . join( ' ', $self->loader->tables ) . '"' )
          if $c->debug;
    }
    return $self;
}

=item $self->table($name)

Returns the class for given table name.

=cut

sub table { shift->loader->find_class(shift) }

=back

=head1 SEE ALSO

L<Catalyst>, L<DBIx::Class> L<Catalyst::Model::DBIC::Schema>

=head1 AUTHOR

Sebastian Riedel, C<sri@cpan.org>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it 
under the same terms as Perl itself.

=cut

1;
