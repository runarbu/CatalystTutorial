package Catalyst::Plugin::Session::Store::DBIC::Delegate;

use strict;
use warnings;
use base qw/Class::Accessor::Fast/;

__PACKAGE__->mk_accessors(qw/model id_field _session_row _flash_row/);

=head1 NAME

Catalyst::Plugin::Session::Store::DBIC::Delegate - Delegates between the session and flash rows

=head1 DESCRIPTION

This class delegates between two rows in your sessions table for a
given session (session and flash).  This is done for compatibility
with L<Catalyst::Plugin::Session::Store::DBI>.

=head1 METHODS

=head2 session

Return the session row for this delegate.

=cut

sub session {
    my ($self, $key) = @_;

    my $row = $self->_session_row;

    unless ($row) {
        $row = $self->model->find_or_create({ $self->id_field => $key });
        $self->_session_row($row);
    }

    return $row;
}

=head2 flash

Return the flash row for this delegate.

=cut

sub flash {
    my ($self, $key) = @_;

    my $row = $self->_flash_row;

    unless ($row) {
        $row = $self->model->find_or_create({ $self->id_field => $key });
        $self->_flash_row($row);
    }

    return $row;
}

=head2 expires

Return the expires row for this delegate.  As with
L<Catalyst::Plugin::Session::Store::DBI>, this maps to the L</session>
row.

=cut

sub expires {
    my ($self, $key) = @_;

    $key =~ s/^expires/session/;
    $self->session($key);
}

=head2 flush

Update the session and flash data in the backend store.

=cut

sub flush {
    my ($self) = @_;

    for (qw/_session_row _flash_row/) {
        my $row = $self->$_;
        $row->update if $row and $row->in_storage;
    }

    $self->_clear_instance_data;
}

=head2 _clear_instance_data

Remove any references held by the delegate.

=cut

sub _clear_instance_data {
    my ($self) = @_;

    $self->id_field(undef);
    $self->model(undef);
    $self->_session_row(undef);
    $self->_flash_row(undef);
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>danieltwc@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2006 Daniel Westermann-Clark, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
