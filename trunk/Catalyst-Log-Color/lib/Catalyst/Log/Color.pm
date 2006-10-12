package Catalyst::Log::Color;

use strict;
use base 'Catalyst::Log';

use Term::ANSIColor ();

if ( $^O eq 'MSWin32' ) {
    require Win32::Console::ANSI;
}

our $VERSION = '0.1';

our %colors = (
     debug => Term::ANSIColor::colored( "%s", 'yellow'  ),
     info  => Term::ANSIColor::colored( "%s", 'green'   ),
     warn  => Term::ANSIColor::colored( "%s", 'blue'    ),
     error => Term::ANSIColor::colored( "%s", 'magenta' ),
     fatal => Term::ANSIColor::colored( "%s", 'red'     )
);

sub colored {
    my ( $self, $level, $string ) = @_;
    return sprintf( $colors{$level}, $string );
}

sub _log {
    my ( $self, $level, @message ) = @_;
    $self->SUPER::_log( $self->colored( $level, $level ), @message );
}

1;

__END__

=head1 NAME

Catalyst::Log::Color - Colored log output

=head1 SYNOPSIS

    MyApp->log( Catalyst::Log::Color->new );



=head1 DESCRIPTION

Colored log output

=head1 SEE ALSO

L<Catalyst>, L<Catalyst::Log>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
