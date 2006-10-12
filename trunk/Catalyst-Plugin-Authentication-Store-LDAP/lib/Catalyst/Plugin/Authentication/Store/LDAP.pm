#!/usr/bin/perl

package Catalyst::Plugin::Authentication::Store::LDAP;

use strict;
use warnings;

our $VERSION = '0.05';

use Catalyst::Plugin::Authentication::Store::LDAP::Backend;

sub setup {
    my $c = shift;

    if (exists($c->config->{'authentication'})) {
        unless (exists($c->config->{'authentication'}->{'ldap'})) {
            Catalyst::Exception->throw("I require \$c->config->{'authentication'}->{'ldap'} to be configured.");
        }
    } else {
        Catalyst::Exception->throw("I require \$c->config->{'authentication'}->{'ldap'} to be configured.");
    }

    $c->default_auth_store(
        Catalyst::Plugin::Authentication::Store::LDAP::Backend->new(
            $c->config->{'authentication'}->{'ldap'}
        )
    );

	$c->NEXT::setup(@_);
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Catalyst::Plugin::Authentication::Store::LDAP 
  - Authentication from an LDAP Directory.

=head1 SYNOPSIS

    use Catalyst qw/
      Authentication
      Authentication::Store::LDAP
      Authentication::Credential::Password
      /;

    __PACKAGE__->config(
        'authentication' => {
            'ldap' => {
                'ldap_server' => 'ldap.yourcompany.com',
                'ldap_server_options' => {
                    'timeout' => 30,
                },
                'binddn' => 'anonymous',
                'bindpw' => 'dontcarehow',
                'start_tls' => 1,
                'start_tls_options' => {
                    'verify' => 'none',
                },
                'user_basedn' => 'ou=people,dc=yourcompany,dc=com',
                'user_filter' => '(&(objectClass=posixAccount)(uid=%s))',
                'user_scope' => 'one',
                'user_field' => 'uid',
                'user_search_options' => {
                    'deref' => 'always',
                },
                'use_roles' => 1,
                'role_basedn' => 'ou=groups,dc=yourcompany,dc=com',
                'role_filter' => '(&(objectClass=posixGroup)(memberUid=%s))',
                'role_scope' => 'one',
                'role_field' => 'uid',
                'role_value' => 'dn',
                'role_search_options' => {
                    'deref' => 'always',
                },
            }
        },
    );

    sub login : Global {
        my ( $self, $c ) = @_;

        $c->login( $c->req->param("login"), $c->req->param("password"), );
        $c->res->body("Welcome " . $c->user->username . "!");
    }

=head1 DESCRIPTION

This plugin uses C<Net::LDAP> to let your application authenticate against
an LDAP directory.  It has a pretty high degree of flexibility, given the 
wide variation of LDAP directories and schemas from one system to another. 

It authenticates users in two steps:

1) A search of the directory is performed, looking for a user object that
   matches the username you pass.  This is done with the bind credentials 
   supplied in the "binddn" and "bindpw" configuration options.

2) If that object is found, we then re-bind to the directory as that object.
   Assuming this is successful, the user is Authenticated.  

=head1 CONFIGURATION OPTIONS

=head2 Configuring with YAML

Set Configuration to be loaded via Config.yml in YourApp.pm

    use YAML qw(LoadFile);
    use Path::Class 'file';

    __PACKAGE__->config(
        LoadFile(
            file(__PACKAGE__->config->{home}, 'Config.yml')
        )
    );

Settings in Config.yml

    # Config for Store::LDAP
    authentication:
        ldap:
            ldap_server: ldap.yourcompany.com
            ldap_server_options:
                timeout: 30
            binddn: anonymous
            bindpw: dontcarehow
            start_tls: 1
            start_tls_options:
                verify: none
            user_basedn: ou=people,dc=yourcompany,dc=com
            user_filter: (&(objectClass=posixAccount)(uid=%s))
            user_scope: one
            user_field: uid
            user_search_options:
                deref: always
            use_roles: 1
            role_basedn: ou=groups,ou=OxObjects,dc=yourcompany,dc=com
            role_filter: (&(objectClass=posixGroup)(memberUid=%s))
            role_scope: one
            role_field: uid
            role_value: dn
            role_search_options:
                deref: always

=head2 ldap_server

This should be the hostname of your LDAP server.

=head2 ldap_server_options

This should be a hashref containing options to pass to L<Net::LDAP>->new().  
See L<Net::LDAP> for the full list.

=head2 binddn

This should be the DN of the object you wish to bind to the directory as
during the first phase of authentication. (The user lookup phase)

If you supply the value "anonymous" to this option, we will bind anonymously
to the directory.  This is the default.

=head2 bindpw

This is the password for the initial bind.

=head2 start_tls

If this is set to 1, we will convert the LDAP connection to use SSL.

=head2 start_tls_options

This is a hashref, which contains the arguments to the L<Net::LDAP> start_tls
method.  See L<Net::LDAP> for the complete list of options.

=head2 user_basedn

This is the basedn for the initial user lookup.  Usually points to the
top of your "users" branch; ie "ou=people,dc=yourcompany,dc=com".

=head2 user_filter

This is the LDAP Search filter used during user lookup.  The special string 
'%s' will be replaced with the username you pass to $c->login.  By default
it is set to '(uid=%s)'.  Other possibly useful filters:

    (&(objectClass=posixAccount)(uid=%s))
    (&(objectClass=User)(cn=%s))

=head2 user_scope

This specifies the scope of the search for the initial user lookup.  Valid
values are "base", "one", and "sub".  Defaults to "sub".

=head2 user_field

This is the attribute of the returned LDAP object we will use for their
"username".  This defaults to "uid".  If you had user_filter set to:

    (&(objectClass=User)(cn=%s))

You would probably set this to "cn". You can also set it to an array,
to allow more than one login field. The first field will be returned
as identifier for the user.

=head2 user_search_options

This takes a hashref.  It will append it's values to the call to
L<Net::LDAP>'s "search" method during the initial user lookup.  See
L<Net::LDAP> for valid options.

Be careful not to specify:

    filter
    scope
    base

As they are already taken care of by other configuration options.

=head2 use_roles

Whether or not to enable role lookups.  It defaults to true; set it to 0 if 
you want to always avoid role lookups.

=head2 role_basedn

This should be the basedn where the LDAP Objects representing your roles are.

=head2 role_filter

This should be the LDAP Search filter to use during the role lookup.  It
defaults to '(memberUid=%s)'.  The %s in this filter is replaced with the value
of the "role_value" configuration option.

So, if you had a role_value of "cn", then this would be populated with the cn
of the User's LDAP object.  The special case is a role_value of "dn", which
will be replaced with the User's DN.

=head2 role_scope

This specifies the scope of the search for the user's role lookup.  Valid
values are "base", "one", and "sub".  Defaults to "sub".

=head2 role_field

Should be set to the Attribute of the Role Object's returned during Role lookup you want to use as the "name" of the role.  Defaults to "CN".

=head2 role_value

This is the attribute of the User object we want to use in our role_filter. 
If this is set to "dn", we will use the User Objects DN.

=head2 role_search_options

This takes a hashref.  It will append it's values to the call to
L<Net::LDAP>'s "search" method during the user's role lookup.  See
L<Net::LDAP> for valid options.

Be careful not to specify:

    filter
    scope
    base

As they are already taken care of by other configuration options.

=head1 METHODS

=head2 setup

This method will populate
L<Catalyst::Plugin::Authentication/default_auth_store> with this object. 

=head1 AUTHORS

Adam Jacob <holoway@cpan.org>

Some parts stolen shamelessly and entirely from
L<Catalyst::Plugin::Authentication::Store::Htpasswd>. 

=head1 THANKS

To nothingmuch, ghenry, castaway and the rest of #catalyst for the help. :)

=head1 SEE ALSO

L<Catalyst::Plugin::Authentication::Store::LDAP>,
L<Catalyst::Plugin::Authentication::Store::LDAP::User>,
L<Catalyst::Plugin::Authentication::Store::LDAP::Backend>,
L<Catalyst::Plugin::Authentication>, 
L<Net::LDAP>

=head1 COPYRIGHT & LICENSE

Copyright (c) 2005 the aforementioned authors. All rights
reserved. This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut


