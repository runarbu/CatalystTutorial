package Catalyst::Plugin::Session::DynamicExpiry;
use base qw/Class::Accessor::Fast/;

use NEXT;

our $VERSION='0.02';

__PACKAGE__->mk_accessors(qw/_session_time_to_live/);

sub session_time_to_live {
    my ( $c, @args ) = @_;

    if ( @args ) {
        $c->_session_time_to_live($args[0]);
        eval { $c->_session->{__time_to_live} = $args[0] };
    }

    return $c->_session_time_to_live || eval { $c->_session->{__time_to_live} };
}

sub calculate_initial_session_expires {
    my $c = shift;
    
    if ( defined( my $ttl = $c->_session_time_to_live ) ) {
        $c->log->debug("Overridden time to live: $ttl") if $c->debug;
        return time() + $ttl;
    }

    return $c->NEXT::calculate_initial_session_expires( @_ );
}

sub calculate_extended_session_expires {
    my $c = shift;


    if ( defined(my $ttl = $c->session_time_to_live) ) {
        $c->log->debug("Overridden time to live: $ttl") if $c->debug;
        return time() + $ttl;
    }

    return $c->NEXT::calculate_extended_session_expires( @_ );
}

sub _save_session {
    my $c = shift;

    if ( my $session_data = $c->_session ) {
        if ( defined( my $ttl = $c->_session_time_to_live ) ) {
            $session_data->{__time_to_live} = $ttl;
        }
    }

    $c->NEXT::_save_session( @_ );
}

1;

=head1 NAME

Catalyst::Plugin::Session::DynamicExpiry - per-session custom expiry times

=head1 SYNOPSIS

    # put Session::DynamicExpiry in your use Catalyst line
    
    if ($c->req->param('remember') { 
      $c->session_time_to_live( 604800 ) # expire in one week.
    }

=head1 DESCRIPTION

This module allows you to expire session cookies indvidually per session.

If the C<session_time_to_live> field is defined it will set expiry to that many
seconds into the future. Note that the session cookie is set on every request,
so a expiry of one week will stay as long as the user visits the site at least
once a week.

Once ttl has been set for a session the ttl will be stored in the
C<__time_to_live> key within the session data itself, and reused for subsequent
request, so you only need to set this once per session (not once per request).

This is unlike the ttl option in the config in that it allows different
sessions to have different times, to implement features like "remember me"
checkboxes.

=head1 METHODS

=head2 session_time_to_live $ttl

To set the TTL for this session use this method.

=head1 OVERRIDDEN METHODS

=head2 calculate_initial_session_expires

=head2 calculate_extended_session_expires

Overridden to implement dynamic expiry functionality.

=head1 SEE ALSO

=head2 L<Catalyst::Plugin::Session> - The new session framework.

=head2 L<Catalyst> - The Catalyst framework itself.

=head1 AUTHOR

Marcus Ramberg, C<mramberg@cpan.org>
Yuval Kogman

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
