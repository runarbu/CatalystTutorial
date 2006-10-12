package Catalyst::Model::LDAP;

use strict;
use warnings;
use base qw/Catalyst::Model/;
use Carp;
use Catalyst::Model::LDAP::Search;
use Data::Page;
use NEXT;
use Net::LDAP;
use Net::LDAP::Constant qw/LDAP_CONTROL_VLVRESPONSE/;
use Net::LDAP::Control::Sort;
use Net::LDAP::Control::VLV;
use Scalar::Util qw/blessed/;

our $VERSION = '0.15';

=head1 NAME

Catalyst::Model::LDAP - LDAP model class for Catalyst

=head1 SYNOPSIS

    # Use the Catalyst helper
    script/myapp_create.pl model Person LDAP ldap.ufl.edu ou=People,dc=ufl,dc=edu

    # Or, in lib/MyApp/Model/Person.pm
    package MyApp::Model::Person;

    use base 'Catalyst::Model::LDAP';

    __PACKAGE__->config(
        host => 'ldap.ufl.edu',
        base => 'ou=People,dc=ufl,dc=edu',
    );

    1;

    # Then, in your controller
    my $mesg = $c->model('Person')->search('(cn=Lou Rhodes)');
    my @entries = $mesg->entries;
    print $entries[0]->sn;

=head1 DESCRIPTION

This is the L<Net::LDAP> model class for Catalyst.  It is nothing more
than a simple wrapper for L<Net::LDAP>.

This class simplifies LDAP access by letting you configure a common
set of bind arguments and options.  It also lets you configure a base
DN for searching.

L<Net::LDAP> methods are supported via Perl's C<AUTOLOAD> mechanism.
Please refer to the L<Net::LDAP> documentation for information on
what's available.

=head1 CONFIGURATION

The following configuration parameters are supported:

=over 4

=item * C<host>

The LDAP server's fully qualified domain name (FQDN),
e.g. C<ldap.ufl.edu>.  Can also be an IP address, e.g. C<127.0.0.1>.

=item * C<base>

The base distinguished name (DN) for searching the directory,
e.g. C<ou=People,dc=ufl,dc=edu>.

=item * C<dn>

(Optional) The bind DN for connecting to the directory,
e.g. C<dn=admin,dc=ufl,dc=edu>.  This can be anyone that has
permission to search under the base DN, as per your LDAP server's
access control lists.

=item * C<password>

(Optional) The password for the specified bind DN.

=item * C<start_tls>

(Optional) Set to C<1> to use TLS when binding to the LDAP server, for
secure connections.

=item * C<start_tls_options>

(Options) A hashref containing options to use when binding using TLS
to the LDAP server.

=item * C<options>

(Optional) A hashref containing options to pass to all L<Net::LDAP>
methods.  For example, this can be used to bind using SASL or to set a
sizelimit for C<search>.

=item * C<entry_class>

(Optional) The class or package name to rebless L<Net::LDAP::Entry>
objects as.  Defaults to L<Catalyst::Model::LDAP::Entry>.

=back

=head1 METHODS

=head2 new

Create a new Catalyst LDAP model component.

=cut

sub new {
    my ($class, $c, $config) = @_;

    my $self = $class->NEXT::new($c, $config);
    $self->config($config);
    $self->config->{entry_class} ||= 'Catalyst::Model::LDAP::Entry';

    return $self;
}

=head2 search 

Search the configured directory using a given filter.  For example:

    my $mesg = $c->model('Person')->search('(cn=Lou Rhodes)');
    my $entry = $mesg->shift_entry;
    print $entry->title;

This method overrides the C<search> method in L<Net::LDAP> to add
paging support.  The following additional options are supported:

=over 4

=item C<page>

Which page to return.

=item C<rows>

Rows to return per page.  Defaults to 25.

=item C<order_by>

Sort the records (on the server) by the specified attribute.  Required
if you use C<page>.

=back

When paging is active, this method returns the server response and a
L<Data::Page> object.  Otherwise, it returns the server response only.

=cut

sub search {
    my $self = shift;
    my %args = scalar @_ == 1 ? (filter => shift) : @_;

    croak "Cannot use 'page' without 'order_by'"
        if $args{page} and not $args{order_by};

    # Use default base
    %args = (
        base => $self->config->{base},
        %args,
    );

    # Handle server-side sorting
    if (my $order_by = delete $args{order_by}) {
        my $sort = Net::LDAP::Control::Sort->new(order => $order_by);

        $args{control} ||= [];
        push @{ $args{control} }, $sort;
    }

    # Handle paging
    if (my $page = delete $args{page}) {
        my $rows = delete $args{rows} || 25;

        my $vlv = Net::LDAP::Control::VLV->new(
            before  => 0,
            after   => $rows - 1,
            content => 0,
            offset  => ($rows * $page) - $rows + 1,
        );

        push @{ $args{control} }, $vlv;

        my $mesg = $self->_execute('search', %args);
        my $resp = $mesg->control(LDAP_CONTROL_VLVRESPONSE) or
            croak 'Could not get pager from LDAP response: ' . $mesg->server_error;

        my $pager = Data::Page->new($resp->content, $rows, $page);

        return ($mesg, $pager);
    }

    # Default to standard search
    return $self->_execute('search', %args);
}

=head1 INTERNAL METHODS

=head2 _client

Bind the client using the current configuration and return it.  This
method is automatically called when you use a L<Net::LDAP> method.

If the C<start_tls> configuration option is present, the client will
use the L<Net::LDAP> C<start_tls> method to make your connection
secure.

=cut

sub _client {
    my ($self) = @_;

    # Default to an anonymous bind
    my @args;
    if ($self->config->{dn}) {
        push @args, $self->config->{dn};
        push @args, password => $self->config->{password}
            if exists $self->config->{password};
        push @args, %{ $self->config->{options} }
            if ref $self->config->{options} eq 'HASH';
    }

    my $client = Net::LDAP->new(
        $self->config->{host},
        %{ ref $self->config->{options} eq 'HASH' ? $self->config->{options} : {} },
    ) or croak $@;

    # Bind using TLS if configured
    if ($self->config->{start_tls}) {
        my $mesg = $client->start_tls(
            %{ ref $self->config->{start_tls_options} eq 'HASH' ? $self->config->{start_tls_options} : {} },
        );
        croak 'LDAP TLS error: ' . $mesg->error if $mesg->is_error;
    }

    my $mesg = $client->bind(@args);
    croak 'LDAP error: ' . $mesg->error if $mesg->is_error;

    return $client;
}

=head2 _execute

Execute the specified LDAP command.  Call the appropriate L<Net::LDAP>
methods directly instead of this method.  For example:

    # In your controller
    my $mesg = $c->model('Person')->search('(cn=Andy Barlow)');

This method will also rebless any L<Net::LDAP::Search> objects as
L<Catalyst::Model::LDAP::Search> objects.

=cut

sub _execute {
    my ($self, $method, @args) = @_;

    my $client = $self->_client;

    my $mesg = $client->$method(
        @args,
        %{ ref $self->config->{options} eq 'HASH' ? $self->config->{options} : {} },
    );

    if (blessed $mesg and $mesg->isa('Net::LDAP::Search')) {
        bless $mesg, 'Catalyst::Model::LDAP::Search';
        $mesg->init($self->config->{entry_class});
    }

    return $mesg;
}

# Based on Catalyst::Plugin::Authentication::Store::DBIC::User
sub AUTOLOAD {
    my ($self, @args) = @_;

    my ($method) = (our $AUTOLOAD =~ /([^:]+)$/);
    return if $method eq 'DESTROY';

    return $self->_execute($method, @args);
}

=head1 SEE ALSO

=over 4

=item * L<Catalyst::Helper::Model::LDAP>

=item * L<Catalyst::Model::LDAP::Search>

=item * L<Catalyst::Model::LDAP::Entry>

=item * L<Catalyst>

=item * L<Net::LDAP>

=back

=head1 AUTHORS

=over 4

=item * Daniel Westermann-Clark E<lt>danieltwc@cpan.orgE<gt>

=item * Adam Jacob E<lt>holoway@cpan.orgE<gt> (TLS support)

=item * Marcus Ramberg (paging support and entry AUTOLOAD)

=back

=head1 ACKNOWLEDGMENTS

=over 4

=item * Salih Gonullu, for initial work on Catalyst mailing list

=item * Christopher H. Laco, for C<AUTOLOAD> idea

=back

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
