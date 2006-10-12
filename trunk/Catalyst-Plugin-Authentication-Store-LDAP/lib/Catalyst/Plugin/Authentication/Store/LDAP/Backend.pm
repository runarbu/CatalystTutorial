#!/usr/bin/perl

=head1 NAME

Catalyst::Plugin::Authentication::Store::LDAP::Backend 
  - LDAP authentication storage backend.

=head1 SYNOPSIS

    # you probably just want Store::LDAP under most cases,
    # but if you insist you can instantiate your own store:

    use Catalyst::Plugin::Authentication::Store::LDAP::Backend;

    use Catalyst qw/
        Authentication
        Authentication::Credential::Password
    /;

    my %config = (
            'ldap_server' => 'ldap1.yourcompany.com',
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
            'role_filter' => '(&(objectClass=posixGroup)(member=%s))',
            'role_scope' => 'one',
            'role_field' => 'cn',
            'role_value' => 'dn',
            'role_search_options' => {
                'deref' => 'always',
            },
    );
    
    our $users = Catalyst::Plugin::Authentication::Store::LDAP::Backend->new(\%config);

    sub action : Local {
        my ( $self, $c ) = @_;

        $c->login( $users->get_user( $c->req->param("login") ),
            $c->req->param("password") );
    }

=head1 DESCRIPTION

You probably want L<Catalyst::Plugin::Authentication::Store::LDAP>, unless
you are mixing several stores in a single app and one of them is LDAP.

Otherwise, this lets you create a store manually. 

See the L<Catalyst::Plugin::Authentication::Store::LDAP> documentation for
an explanation of the configuration options.

=head1 METHODS

=cut

package Catalyst::Plugin::Authentication::Store::LDAP::Backend;
use base qw/Class::Accessor::Fast/;

use strict;
use warnings;

use Catalyst::Plugin::Authentication::Store::LDAP::User;
use Net::LDAP;

BEGIN {
    __PACKAGE__->mk_accessors(
        qw/ldap_server ldap_server_options binddn bindpw user_search_options user_filter user_basedn user_scope user_attrs user_field use_roles role_basedn role_filter role_scope role_field role_value role_search_options start_tls start_tls_options/
    );
}

=head2 new($config)

Creates a new L<Catalyst::Plugin::Authentication::Store::LDAP::Backend> object.
$config should be a hashref, which should contain the configuration options
listed in L<Catalyst::Plugin::Authentication::Store::LDAP>'s documentation.

Also sets a few sensible defaults.

=cut

sub new {
    my ($class, $config) = @_;
    
    unless (defined($config) && ref($config) eq "HASH") {
        Catalyst::Exception->throw("Catalyst::Plugin::Authentication::Store::LDAP::Backend needs to be configured with a hashref."); 
    }
    my %config_hash = %{$config};
    $config_hash{'binddn'}      ||= 'anonymous';
    $config_hash{'user_filter'} ||= '(uid=%s)';
    $config_hash{'user_scope'}  ||= 'sub';
    $config_hash{'user_field'}  ||= 'uid';
    $config_hash{'role_filter'} ||= '(memberUid=%s)';
    $config_hash{'role_scope'}  ||= 'sub';
    $config_hash{'role_field'}  ||= 'cn';
    $config_hash{'use_roles'}   ||= '1';
    $config_hash{'start_tls'}   ||= '0';
    my $self = \%config_hash;
    bless($self, $class);
    return $self;
}

=head2 get_user($id)

Creates a L<Catalyst::Plugin::Authentication::Store::LDAP::User> object
for the given User ID.  This is the preferred mechanism for getting a 
given User out of the Store.

=cut

sub get_user {
    my ($self, $id) = @_;
    my $user = Catalyst::Plugin::Authentication::Store::LDAP::User->new($self, $self->lookup_user($id));
    return $user;
}

=head2 ldap_connect

Returns a L<Net::LDAP> object, connected to your LDAP server. (According
to how you configured the Backend, of course)

=cut

sub ldap_connect {
    my ($self) = shift;
    my $ldap;
    if (defined($self->ldap_server_options())) {
        $ldap = Net::LDAP->new($self->ldap_server, %{ $self->ldap_server_options }) or Catalyst::Exception->throw($@);
    } else {
        $ldap = Net::LDAP->new($self->ldap_server) or Catalyst::Exception->throw($@);
    }
    if (defined($self->start_tls) && $self->start_tls =~ /(1|true)/i) {
        my $mesg;
        if (defined($self->start_tls_options)) {
            $mesg = $ldap->start_tls(%{ $self->start_tls_options });
        } else {
            $mesg = $ldap->start_tls;
        }
        if ($mesg->is_error) {
            Catalyst::Exception->throw("TLS Error: " . $mesg->error);
        }
    }
    return $ldap;
}

=head2 ldap_bind($ldap, $binddn, $bindpw)

Bind's to the directory.  If $ldap is undef, it will connect to the
LDAP server first.  $binddn should be the DN of the object you wish
to bind as, and $bindpw the password.

If $binddn is "anonymous", an anonymous bind will be performed.

=cut

sub ldap_bind {
    my ($self, $ldap, $binddn, $bindpw, $forauth) = @_;
    $forauth ||= 0;
    $ldap ||= $self->ldap_connect;
    if (!defined($ldap)) {
        Catalyst::Exception->throw("LDAP Server undefined!");
    }
    $binddn ||= $self->binddn;
    $bindpw ||= $self->bindpw;
    if ($binddn eq "anonymous") {
        my $mesg = $ldap->bind;
        if ($mesg->is_error) {
            Catalyst::Exception->throw("Error on Bind: " . $mesg->error);
        }
    } else {
        if ($bindpw) {
            my $mesg = $ldap->bind($binddn, 'password' => $bindpw);
            if ($mesg->is_error) {
                # If we're not checking this bind for authentication purposes
                # Go ahead an blow up if we fail.
                if ($forauth ne 'forauth') {
                    Catalyst::Exception->throw("Error on Initial Bind: " . $mesg->error);
                } else {
                    return undef;
                }
            }
        } else {
            my $mesg = $ldap->bind($binddn);
            if ($mesg->is_error) {
                return undef;
            }
        }
    }
    return $ldap;
}

=head2 lookup_user($id)

Given a User ID, this method will:

  A) Bind to the directory using the configured binddn and bindpw
  B) Perform a search for the User Object in the directory, using
     user_basedn, user_filter, and user_scope.
  C) Assuming we found the object, we will walk it's attributes 
     using L<Net::LDAP::Entry>'s get_value method.  We store the
     results in a hashref.
  D) Return a hashref that looks like: 
     
     $results = {
        'ldap_entry' => $entry, # The Net::LDAP::Entry object
        'attributes' => $attributes,
     }

This method is usually only called by get_user.

=cut

sub lookup_user {
    my ($self, $id) = @_;

    # No sneaking in wildcards!
    if ($id =~ /\*/) {
        Catalyst::Exception->throw("ID $id contains wildcards!");
    }
    my $ldap = $self->ldap_bind;
    my @searchopts;
    if (defined($self->user_basedn)) {
        push(@searchopts, 'base' => $self->user_basedn);
    } else {
        Catalyst::Exception->throw("You must set user_basedn before looking up users!");
    }
    my $filter = $self->_replace_filter($self->user_filter, $id);
    push(@searchopts, 'filter' => $filter);
    push(@searchopts, 'scope'  => $self->user_scope);
    if (defined($self->user_search_options)) {
        push(@searchopts, %{ $self->user_search_options });
    }
    my $usersearch = $ldap->search(@searchopts);
    if ($usersearch->is_error) {
        Catalyst::Exception->throw("LDAP Error while searching for user: " . $usersearch->error);
    }
    my $userentry;
    my $user_field=$self->user_field;
    my @user_fields=ref $user_field eq 'ARRAY' ? @$user_field : ( $user_field) ;
  RESULT: while (my $entry = $usersearch->pop_entry) {
        foreach my $field (@user_fields) {
            foreach my $value ($entry->get_value($field)) {
                if ($value eq $id) {
                    $userentry = $entry;
                    last RESULT;
                }
            }
        }
    }
    $ldap->unbind;
    $ldap->disconnect;
    unless ($userentry) {
        return undef;
    }
    my $attrhash;
    foreach my $attr ($userentry->attributes) {
        my @attrvalues = $userentry->get_value($attr);
        if (scalar(@attrvalues) == 1) {
            $attrhash->{ lc($attr) } = $attrvalues[0];
        } else {
            $attrhash->{ lc($attr) } = \@attrvalues;
        }
    }
    eval {require Catalyst::Model::LDAP::Entry;};
    if(!$@) {
        bless($userentry,'Catalyst::Model::LDAP::Entry');
        $userentry->{_use_unicode}++;
    }
    my $rv = {
        'ldap_entry' => $userentry,
        'attributes' => $attrhash,
    };
    return $rv;
}

=head2 lookup_roles($userobj)

This method looks up the roles for a given user.  It takes a 
L<Catalyst::Plugin::Authentication::Store::LDAP::User> object
as it's sole argument.

It returns an array containing the role_field attribute from all the
objects that match it's criteria.

=cut

sub lookup_roles {
    my ($self, $userobj) = @_;
    if ($self->use_roles == 0 || $self->use_roles =~ /^false$/i) {
        return undef;
    }
    my $ldap = $self->ldap_bind;
    my @searchopts;
    if (defined($self->role_basedn)) {
        push(@searchopts, 'base' => $self->role_basedn);
    } else {
        Catalyst::Exception->throw("You must set up role_basedn before looking up roles!");
    }
    my $filter_value = $userobj->has_attribute($self->role_value);
    if (!defined($filter_value)) {
        Catalyst::Exception->throw("User object " . $userobj->username . " has no " . $self->role_value . " attribute, so I can't look up it's roles!");
    }
    my $filter = $self->_replace_filter($self->role_filter, $filter_value);
    push(@searchopts, 'filter' => $filter);
    push(@searchopts, 'scope'  => $self->role_scope);
    push(@searchopts, 'attrs'  => [ $self->role_field ]);
    if (defined($self->role_search_options)) {
        push(@searchopts, %{ $self->role_search_options });
    }
    my $rolesearch = $ldap->search(@searchopts);
    my @roles;
  RESULT: while (my $entry = $rolesearch->pop_entry) {
        my ($role) = $entry->get_value($self->role_field);
        if ($role) {
            push(@roles, $role);
        } else {
            next RESULT;
        }
    }
    return @roles;
}

sub _replace_filter {
    my $self    = shift;
    my $filter  = shift;
    my $replace = shift;
    $filter =~ s/\%s/$replace/g;
    return $filter;
}

sub user_supports {
    my $self = shift;

    # this can work as a class method
    Catalyst::Plugin::Authentication::Store::LDAP::User->supports(@_);
}

sub from_session {
    my ($self, $c, $id) = @_;
    $self->get_user($id);
}

__PACKAGE__;

__END__

=head1 AUTHORS

Adam Jacob <holoway@cpan.org>

Some parts stolen shamelessly and entirely from
L<Catalyst::Plugin::Authentication::Store::Htpasswd>. 

=head1 THANKS

To nothingmuch, ghenry, castaway and the rest of #catalyst for the help. :)

=head1 SEE ALSO

L<Catalyst::Plugin::Authentication::Store::LDAP>, L<Catalyst::Plugin::Authentication::Store::LDAP::User>, L<Catalyst::Plugin::Authentication>, L<Net::LDAP>

=head1 COPYRIGHT & LICENSE

Copyright (c) 2005 the aforementioned authors. All rights
reserved. This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut

