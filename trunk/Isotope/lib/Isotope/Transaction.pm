package Isotope::Transaction;

use strict;
use warnings;
use base 'Isotope::Object';

use Moose qw[has];

has 'connection'  => ( isa       => 'Isotope::Connection',
                       is        => 'rw',
                       required  => 1,
                       trigger   => sub {
                           my ( $self, $connection ) = @_;
                           $connection->transaction($self);
                       });

has 'request'     => ( isa       => 'Isotope::Request',
                       is        => 'rw',
                       required  => 1,
                       trigger   => sub {
                           my ( $self, $request ) = @_;
                           $request->transaction($self);
                       });

has 'response'    => ( isa       => 'Isotope::Response',
                       is        => 'rw',
                       required  => 1,
                       trigger   => sub {
                           my ( $self, $response ) = @_;
                           $response->transaction($self);
                       });

has 'stash'       => ( isa       => 'HashRef',
                       reader    => 'get_stash',
                       writer    => 'set_stash',
                       predicate => 'has_stash',
                       required  => 1,
                       lazy      => 1,
                       default   => sub { {} } );

sub stash {
    my $self  = shift;
    my $stash = $self->get_stash;

    if ( @_ == 0 ) {
        return wantarray ? keys %{ $stash } : $stash;
    }

    if ( @_ == 1 ) {

        unless ( exists $stash->{ $_[0] } ) {
            return wantarray ? () : undef;
        }

        unless ( wantarray ) {
            return $stash->{ $_[0] };
        }

        if ( ref $stash->{ $_[0] } eq 'ARRAY' ) {
            return @{ $stash->{ $_[0] } };
        }

        if ( ref $stash->{ $_[0] } eq 'HASH' ) {
            return %{ $stash->{ $_[0] } };
        }

        return ( $stash->{ $_[0] } );
    }
    
    my $return = delete $stash->{ $_[0] };

    unless ( @_ == 2 && ! defined $_[1] ) {
        $stash->{ $_[0] } = @_ > 2 ? [ @_[ 1 .. $#_ ] ] : $_[1];
    }

    return $return;
}

1;

__END__

=head1 NAME

Isotope::Transaction - Isotope Transaction Class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item new

=item connection

=item request

=item response

=item stash

=back

=head1 SEE ALSO

L<Isotope::Connection>.

L<Isotope::Message>.

L<Isotope::Request>.

L<Isotope::Response>.

=head1 AUTHOR

Christian Hansen C<ch@ngmedia.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify 
it under the same terms as Perl itself.

=cut
