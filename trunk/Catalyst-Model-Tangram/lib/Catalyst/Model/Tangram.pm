package Catalyst::Model::Tangram;

use Class::Tangram::Generator;
use Tangram;
use strict;
use base qw/Catalyst::Base/;
use NEXT;

=head1 NAME

Catalyst::Model::Tangram - Catalyst Model class for Tangram databases

=head1 SYNOPSIS

  # use the helper
  create model Tangram dsn user password

  # lib/MyApp/Model/Tangram.pm
  package MyApp::Model::Tangram;

  use base ’Catalyst::Model::Tangram;

  __PACKAGE__‐>config(
      dsn           => ’dbi:Pg:dbname=myapp’,
      password      => ’’,
      user          => ’postgres’,
      relationships => 1
  );

  1;

  # need examples of usage here...

=head1 DESCRIPTION

This is the model class for using Tangram with Catalyst applications.

Of course, it doesn't actually provide an abstracted model class, no
parts of Catalyst do that (or a view, or a controller class).  No,
this just wraps Tangram in a module that contains the word "Catalyst"
in it, so that you don't I<feel> that you're coding your application
for a particular database abstraction API.  Of course, you still are.

If you want real MVC abstraction for building your applications, you
should wait for C<Catalyst::Plugin::Bamboo>.

=cut

our $VERSION = '0.01';

__PACKAGE__->mk_accessors('storage');
__PACKAGE__->mk_accessors('gen');

sub new
{
    my ( $self, $c ) = @_;
    $self = $self->NEXT::new($c);
    my %config = (
        options => {},

        # this can have options here!

        %{ $self->config() },
                 );
    $self->{schema}  = $config{schema};
    $self->{gen}     = new Class::Tangram::Generator $self->{schema};
    $self->{storage} = Tangram::Storage->connect
	( Tangram::Schema->new( $self->{schema} ),
	  $config{dsn}, $config{user}, $config{password},
	  %{ $config{options} } );

    return $self;
}

# TODO
# # helper
# # schema helper
# # error checking
# # debug
# # dbi options, etc
# # document
# # add tangram debug option per-class

1;

=head1 AUTHOR

Andres Kievsky, C<ank@cpan.org>

=cut

