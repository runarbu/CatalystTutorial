package Catalyst::Model::Flickr;

use strict;
use warnings;
use base qw/Catalyst::Model Class::Data::Accessor/;
use NEXT;

use Carp;
use Flickr::API;
use Flickr::Upload;

use Data::Dumper;
our $VERSION = '0.01';


__PACKAGE__->mk_accessors(qw/flickr frob auth_url token/);

sub new
{
    my $self = shift->NEXT::new(@_);
    
    if(!($self->{api_key} && $self->{secret}))
    {
        croak "->config->{api_key} and ->config->{secret} must be defined for this model";
    }
    my $auth_type = $self->{auth_type} && $self->{auth_type} eq 'desktop' ? 'desktop' : 'web';
    my $permission = $self->{permissions} ? $self->{permissions} : 'write';
    
    my $flickr = Flickr::Upload->new({ key => $self->{api_key},
                                    secret => $self->{secret} });
    my $res = $flickr->execute_method('flickr.auth.getFrob');
    croak "Failed to fetch frob" if(!$res->{success});
    my $frob = $res->{tree}->{children}[1]{children}[0]{content};
    $self->frob($frob);
#    print STDERR Dumper($res->{tree});
    $self->flickr($flickr);
    $self->{is_public} ||= 1;
    $self->{is_friend} ||= 1;
    $self->{is_family} ||= 1;
    $self->auth_url($flickr->request_auth_url($permission, $frob));

    return $self;
}

sub execute_method
{
    my ($self) = shift;

    $self->flickr->execute_method(@_);
}

sub upload
{
    my ($self) = shift;
    $self->flickr->upload(@_);
}

sub is_authenticated
{
    my ($self) = @_;

    return 1 if($self->token);
    return 0 if(!$self->frob);

    my $res = $self->execute_method('flickr.auth.getToken',
                                    { frob => $self->frob });

#    print STDERR Dumper($res);
    return 0 if(!$res->{success});

    $self->token($res->{tree}{children}[1]{children}[1]{children}[0]{content});
    
    return 1;
}

1;

=head1 NAME

Catalyst::Model::Flickr - Accessing flickr accounts from Catalyst.

=head1 SYNOPSIS

  # Create a flickr model:
  package MyApp::Model::MyFlickr;
  use base 'Catalyst::Model::Flickr';

  # Configure:
     'Model::MyFlickr' => { 
        api_key => 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
        secret  => 'YYYYYYYYYYYY',
        auth_type => 'desktop',
        permissions => 'write',
     }


  # Get the user to authenticate with your app:
  [% c.model('MyFlickr').auth_url %]

  # Upload a file:
  my $post_to = $c->model('MyFlickr');
  $post_to->upload(
                'photo'      => "$file", 
                'auth_token' => $post_to->token,
                'tags'       => $tags,
                'is_public'  => $post_to->{is_public},
                'is_friend'  => $post_to->{is_friend},
                'is_family'  => $post_to->{is_family},
                'async'      => 1,
                );


=head1 DESCRIPTION

This module allows you to use Flickr, L<http://www.flickr.com>, as a
model with Catalyst. This means you can get users of your application
to authenticate with their existing flickr accounts, allowing the app
to communicate with flickr for them. This does not involve your
application knowing their credentials, instead the application
transparently creates a key, called a "frob", which is then associated
with the logged in user, by flickr.com. See L<Flickr::API> and
L<Flickr::Upload> for more details if needed.

A Model::Flickr object is setup for you by Catalyst upon load, this
can then be accessed via $c->model('MyFlickr') (see synopsis). Pass
through calls for C<execute_method> and C<upload> are provided, as
well as a method to create a URL for user authentication, and an
C<is_authenticated> method.


=head1 CONFIGURATION

The following config keys are used:

=over 4

=item api_key

This is your Flickr API key which is unique per application.

=item secret

This is the Flickr secret token.

=item auth_type

This can be set to 'desktop' or 'web', 'web' is the default.

=item permissions

The available permissions are 'read', 'write' and 'delete'. 'write' is the default.

=item is_public

Upload photos with public viewing turned on (true) or off (false). Default is on.

=item is_friend

Upload photos with friend-viewing turned on (true) or off (false). Default is on.

=item is_family

Upload photos with family-viewing turned on (true) or off (false). Default is on.

=back

=head1 METHODS

=over 4

=item auth_url

Returns a string containing a url you can send users to allow them to
authenticate with Flickr to use your application.

=item execute_method

Calls execute_method on the L<Flickr::API> object, see there and the
flickr.com API documentation for details.

=item upload

Calls upload on the L<Flickr::Upload> object, see there and the
flickr.com API documentation for details.

=item is_authenticated

Returns true if we have an authenticated token.

=item frob

Fetches the frob directly, if needed.

=item token

Returns the currently authenticated token, needed for passing to C<upload>.

=item flickr

Returns the underlying L<Flickr::Upload> / L<Flickr::API> object.

=back

=head1 DEPENDENCIES

Modules used, version dependencies, core yes/no

L<Flickr::API>

L<Flickr::Upload>

L<Catalyst>

L<Carp>

L<Data::Dumper>

=head1 AUTHOR

Jess Robinson <cpan@desert-island.demon.co.uk>


