package Catalyst::Log::Dispatch::Config;

use strict;
use base qw[Log::Dispatch::Config Catalyst::Log::Dispatch];

our $VERSION = '0.1';

sub log {
    my $self  = shift;
    my $depth = $Log::Dispatch::Config::CallerDepth;

    unless ( $depth > 0 ) {
        $depth = 2;
    }

    local $Log::Dispatch::Config::CallerDepth = $depth;

    $self->SUPER::log(@_);
}

1;

__END__

=head1 NAME

Catalyst::Log::Dispatch::Config - Log::Dispatch::Config

=head1 SYNOPSIS

    use Catalyst::Log::Dispatch::Config;

    Catalyst::Log::Dispatch::Config->configure('/path/to/log.conf');

    MyApp->log( Catalyst::Log::Dispatch::Config->instance );


=head1 DESCRIPTION

=head1 SEE ALSO

L<Log::Dispatch::Config>, L<Catalyst::Log::Dispatch>, L<Catalyst::Log>, L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
