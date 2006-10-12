package Catalyst::Log::Dispatch;

use strict;
use base 'Log::Dispatch';

our $VERSION = '0.1';

BEGIN {

    my %map = (
        debug => 'debug',
        info  => 'info',
        warn  => 'warning',
        error => 'error',
        fatal => 'emergency'
    );

    no strict 'refs';

    while ( my ( $level, $dispatch ) = each %map ) {

        *{$level} = sub {
            my ( $self, @message ) = @_;
            $self->log( level => $dispatch, message => "@message" );
        };

        *{"is_$level"} = sub {
            my $self = shift;
            return $self->would_log($dispatch);
        };
    }
}

1;

__END__

=head1 NAME

Catalyst::Log::Dispatch - Log::Dispatch

=head1 SYNOPSIS

    use Catalyst::Log::Dispatch;

    my $dispatcher = Catalyst::Log::Dispatch->new;

    $dispatcher->add( Log::Dispatch::File->new( name      => 'file1',
                                                min_level => 'debug',
                                                filename  => 'logfile' ) );

    MyApp->log($dispatcher);


=head1 DESCRIPTION

=head1 SEE ALSO

L<Log::Dispatch>, L<Catalyst::Log::Dispatch::Config>, L<Catalyst::Log>, L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
