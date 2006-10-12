package Catalyst::Model::T2;

use T2::Schema;
use strict;
use base qw/Catalyst::Base/;
use NEXT;

our $VERSION = '0.01';

=head1 NAME

Catalyst::Model::T2 - Catalyst Model class for T2 databases

=head1 SYNOPSIS

  # use the helper
  create model T2 dsn user password

  # lib/MyApp/Model/T2.pm
  package MyApp::Model::T2;

  use base ’Catalyst::Model::T2;

  __PACKAGE__‐>config( schema => "myapp" );

  1;

  # need examples of usage here...

=head1 DESCRIPTION

This is the model class for using T2 with Catalyst applications.

Of course, it doesn't actually provide an abstracted model class, no
parts of Catalyst do that (or a view, or a controller class).  No,
this just wraps T2 in a module that contains the word "Catalyst" in
it, so that you don't I<feel> that you're coding your application for
a particular database abstraction API.  Of course, you still are.

If you want real MVC abstraction for building your applications, you
should wait for C<Catalyst::Plugin::Bamboo>.

=cut

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

    $self->{schema}  = $config{schema};  # a T2::Schema object
    $self->{schema}  = T2::Schema->read($self->{schema})
	if !ref $self->{schema};         # or a named schema
    $self->{gen}     = $config{schema}->generator;
    $self->{storage} = T2::Storage->connect
	( $config{schema}->schema,
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

Sam Vilain, <samv@cpan.org>

=cut

