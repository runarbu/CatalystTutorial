package Catalyst::Plugin::Session::DynamicExpiry;

use NEXT;

our $VERSION='0.01';

use base qw/Catalyst::Plugin::Session::State/;

sub calculate_extended_session_expires {
    my $c = shift;
    if ( exists $c->session->{__time_to_live} ) {
        return time() + $c->session->{__time_to_live};
    } else {
        return $c->NEXT::calculate_extended_session_expires( @_ );
    }
}

1;

=head1 NAME

Catalyst::Plugin::Session::DynamicExpiry - set expiry of cookies per session

=head1 SYNOPSIS

    # put Session::DynamicExpiry in your use Catalyst line
    
    if ($c->req->param('remember') { 
      $c->session->{__time_to_live}=604800 # expire in one week.
    }

=head1 DESCRIPTION

This module allows you to expire session cookies indvidually per session. If loaded,
it looks for a C<__cookie_time_to_live> key in the session hash, and sets expiry to that 
many seconds into the future. Note that the session cookie is set on every request, 
so a expiry of one week will stay as long as the user visits the site at least once
a week.

=head1 OVERRIDDEN METHODS

=head2 calc_cookie_expiry

Overridden to implement dynamic expiry functionality.

=head1 SEE ALSO

=head2 L<Catalyst::Plugin::Session> - The new session framework.

=head2 L<Catalyst> - The Catalyst framework itself.

=head1 AUTHOR

Marcus Ramberg, C<mramberg@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
