package Catalyst::Plugin::Browser;

use strict;
use Catalyst::Request;
use HTTP::BrowserDetect;

our $VERSION = '0.03';

{
    package Catalyst::Request;

    sub browser {
        my $self = shift;

        unless ( $self->{browser} ) {
            $self->{browser} = HTTP::BrowserDetect->new( $self->user_agent );
        }

        return $self->{browser};
    }
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Browser - Browser Detection

=head1 SYNOPSIS

    use Catalyst qw[Browser];

    if ( $c->request->browser->windows && $c->request->browser->ie ) {
        # do something
    }


=head1 DESCRIPTION

Extends C<Catalyst::Request> with browser detection.

=head1 METHODS

=over 4

=item browser

Returns an instance of L<HTTP::BrowserDetect>, which lets you get
information of the client's user agent.

=back

=head1 SEE ALSO

L<HTTP::BrowserDetect>, L<Catalyst::Request>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>
Marcus Ramberg, C<mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
