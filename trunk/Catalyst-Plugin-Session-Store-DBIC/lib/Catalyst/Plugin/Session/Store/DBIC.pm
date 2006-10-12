package Catalyst::Plugin::Session::Store::DBIC;

use strict;
use warnings;
use base qw/Class::Data::Inheritable Catalyst::Plugin::Session::Store/;
use Catalyst::Exception;
use MIME::Base64;
use NEXT;
use Storable qw/nfreeze thaw/;

our $VERSION = '0.03';

__PACKAGE__->mk_classdata(qw/_dbic_session_obj/);

sub setup_session {
    my $c = shift;

    $c->NEXT::setup_session(@_);

    Catalyst::Exception->throw(
        message => __PACKAGE__ . qq/: You must provide a value for dbic_class/
    ) unless $c->config->{session}->{dbic_class};
}

sub setup_finished {
    my $c = shift;

    return $c->NEXT::setup_finished unless @_;

    my $config = $c->config->{session};

    # Store a reference to the configured session class or object
    my $dbic_class = $config->{dbic_class};
    my $model      = $c->model($dbic_class) || $c->comp($dbic_class);

    my $obj = ref $model ? $model
        : $dbic_class->can('resultset_instance') ? $dbic_class->resultset_instance
        : $dbic_class;
    $c->_dbic_session_obj($obj);

    # Try to determine id_field if it isn't set
    my @primaries = $c->_dbic_session_obj->result_source->primary_columns;
    if (scalar @primaries > 1 and not exists $config->{id_field}) {
        Catalyst::Exception->throw(
            message => __PACKAGE__ . qq/: Primary key consists of more than one column; please set id_field manually/
        );
    }

    # Set default values
    $config->{id_field}      ||= $primaries[0] || 'id';
    $config->{data_field}    ||= 'session_data';
    $config->{expires_field} ||= 'expires';

    $c->NEXT::setup_finished(@_);
}

sub get_session_data {
    my ($c, $key) = @_;

    my $config = $c->config->{session};

    # Optimize for expires:sid
    my $expires = 0;
    if (my ($sid) = $key =~ /^expires:(.*)/) {
        $key     = "session:$sid";
        $expires = 1;
    }

    my $session = $c->_dbic_session_obj->find($key);
    return unless $session;

    if ($expires) {
        return $session->get_column($config->{expires_field});
    }
    else {
        if (my $data = $session->get_column($config->{data_field})) {
            return thaw(decode_base64($data));
        }
    }
}

sub store_session_data {
    my ($c, $key, $data) = @_;

    my $config = $c->config->{session};

    # expires:sid keys only update the expiration time
    if (my ($sid) = $key =~ /^expires:(.*)/) {
        $key = "session:$sid";

        my $session = $c->_dbic_session_obj->find($key);
        return unless $session;

        $session->set_column($config->{expires_field}, $c->session_expires);
        $session->update;
    }
    else {
        my $frozen  = encode_base64(nfreeze($data));
        my $expires = $key =~ /^(?:session|flash):/
            ? $c->session_expires
            : undef;

        my $session = $c->_dbic_session_obj->update_or_create({
            $config->{id_field}      => $key,
            $config->{data_field}    => $frozen,
            $config->{expires_field} => $expires,
        });
    }
}

sub delete_session_data {
    my ($c, $key) = @_;

    return if $key =~ /^expires/;

    my $config = $c->config->{session};

    $c->_dbic_session_obj->search({
        $config->{id_field} => $key,
    })->delete_all;
}

sub delete_expired_sessions {
    my $c = shift;

    my $config = $c->config->{session};

    $c->_dbic_session_obj->search({
        $config->{expires_field} => { '<', time() },
    })->delete_all;
}

1;

__END__

=pod

=head1 NAME

Catalyst::Plugin::Session::Store::DBIC - Store your sessions via DBIx::Class

=head1 SYNOPSIS

    # Create a table in your database for sessions
    CREATE TABLE sessions (
        id           CHAR(72) PRIMARY KEY,
        session_data TEXT,
        expires      INTEGER
    );

    # Create the corresponding table class
    package MyApp::Schema::Session;

    use base qw/DBIx::Class/;

    __PACKAGE__->load_components(qw/Core/);
    __PACKAGE__->table('sessions');
    __PACKAGE__->add_columns(qw/id session_data expires/);
    __PACKAGE__->set_primary_key('id');

    1;

    # In your application
    use Catalyst qw/Session Session::Store::DBIC Session::State::Cookie/;

    __PACKAGE__->config(
        # ... other items ...
        session => {
            dbic_class => 'DBIC::Session',  # Assuming MyApp::Model::DBIC
            expires    => 3600,
        },
    );

    # Later, in a controller action
    $c->session->{foo} = 'bar';

=head1 DESCRIPTION

This L<Catalyst::Plugin::Session> storage module saves session data in
your database via L<DBIx::Class>.

=head1 CONFIGURATION

The following parameters should be placed in your application
configuration under the C<session> key.

=head2 dbic_class

(Required) The name of the L<DBIx::Class> that represents a session in
the database.  Can be the full class name or just the model name
(i.e. the part after C<MyApp::Model>).

If you are using L<Catalyst::Model::DBIC::Schema>, the following
layout is recommended:

=over 4

=item * C<MyApp::Schema> - your L<DBIx::Class::Schema> class

=item * C<MyApp::Schema::Session> - your session table class

=item * C<MyApp::Model::DBIC> - your L<Catalyst::Model::DBIC::Schema> class

=back

This module will then use C<< $c->model >> to access the appropriate
result source from the composed schema matching the C<dbic_class>
name.

For more information, please see L<Catalyst::Model::DBIC::Schema>.

=head2 expires

Number of seconds for which sessions are active.

Note that no automatic cleanup is done on your session data.  To
delete expired sessions, you can use the L</delete_expired_sessions>
method with L<Catalyst::Plugin::Scheduler>.

=head2 id_field

The name of the field on your sessions table which stores the session
ID.  Defaults to C<id>.

=head2 data_field

The name of the field on your sessions table which stores session
data.  Defaults to C<session_data> for compatibility with
L<Catalyst::Plugin::Session::Store::DBI>.

=head2 expires_field

The name of the field on your sessions table which stores the
expiration time of the session.  Defaults to C<expires>.

=head1 SCHEMA

Your sessions table should contain the following columns:

    id           CHAR(72) PRIMARY KEY
    session_data TEXT
    expires      INTEGER

The C<id> column should probably be 72 characters.  It needs to handle
the longest string that can be returned by
L<Catalyst::Plugin::Session/generate_session_id>, plus another eight
characters for internal use.  This is less than 72 characters when
SHA-1 or MD5 is used, but SHA-256 will need all 72 characters.

The C<session_data> column should be a long text field.  Session data
is encoded using L<MIME::Base64> before being stored in the database.

The C<expires> column stores the future expiration time of the
session.  This may be null for per-user and flash sessions.

Note that you can change the column names using the L</id_field>,
L</data_field>, and L</expires_field> configuration parameters.
However, the column types must match the above.

=head1 INTERNAL METHODS

=head2 setup_session

Verify that the configuration is valid, i.e. that a value for the
C<dbic_class> configuration parameter is provided.

=head2 setup_finished

Hook into the configured session class.

=head2 get_session_data

Required method for a L<Catalyst::Plugin::Session::Store>.

=head2 store_session_data

Required method for a L<Catalyst::Plugin::Session::Store>.

=head2 delete_session_data

Required method for a L<Catalyst::Plugin::Session::Store>.

=head2 delete_expired_sessions

Required method for a L<Catalyst::Plugin::Session::Store>.

=head1 AUTHOR

Daniel Westermann-Clark, E<lt>danieltwc@cpan.orgE<gt>

=head1 ACKNOWLEDGMENTS

=over 4

=item * Andy Grundman, for L<Catalyst::Plugin::Session::Store::DBI>

=item * David Kamholz, for most of the testing code (from
        L<Catalyst::Plugin::Authentication::Store::DBIC>)

=back

=head1 COPYRIGHT

Copyright 2006 Daniel Westermann-Clark, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
