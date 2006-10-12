package Catalyst::Model::SPOPS;

use strict;
use base qw[Catalyst::Base];

use NEXT;
use SPOPS;
use SPOPS::ClassFactory;
use SPOPS::Initialize;
use Log::Log4perl;

our $VERSION = '0.01';

sub new {
    my ( $self, $c ) = @_;

    $self = $self->NEXT::new($c);

    my $classes = SPOPS::Initialize->process( { config => $self->config } );

    while ( my $class = shift @{ $classes } ) {

         if ( $class eq __PACKAGE__ ) {
             no strict 'refs';
             *{"$class\::new"} = \&SPOPS::new;
         }

         $c->components->{$class} = $class;
    }

    return $self;
}

1;

__END__

=head1 NAME

Catalyst::Model::SPOPS - SPOPS Model Class

=head1 SYNOPSIS

    # use the helper
    create model SPOPS SPOPS

    # lib/MyApp/Model/SPOPS.pm
    package MyApp::Model::SPOPS;

    use base 'Catalyst::Model::SPOPS';

    __PACKAGE__->config(
        article => {
            class          => 'MyApp::Model::Article',
            isa            => [ 'SPOPS::Key::UUID', 'SPOPS::DBI' ],
            rules_from     => [ 'SPOPS::Tool::DBI::Datasource', 
                                'SPOPS::Tool::DBI::DiscoverField',
                                'SPOPS::Tool::DBI::FindDefaults' ],
            base_table     => 'article',
            id_field       => 'article_id',
            field_discover => 'yes',
            dbi_config     => {
                dsn      => 'DBI:mysql:test:localhost',
                username => 'catalyst',
                password => 'welcome'
            }
        }
    );

    1;

    # As object method
    $c->comp('MyApp::Model::Article')->fetch($id);

    # As class method
    MyApp::Model::Article->fetch($id);

=head1 DESCRIPTION

This is the C<SPOPS> model class.

=head2 new

Initializes SPOPS and loads classes using the class
config.

=head1 SEE ALSO

L<Catalyst>, L<SPOPS>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it 
under the same terms as Perl itself.

=cut
