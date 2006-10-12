package Image::Simple::Imager;

use strict;
use base 'Image::Simple::Adaptor';

use Carp ();
use Imager;

sub open {
    my ( $self, $path ) = @_;

    my $adaptee = Imager->new;

    unless ( $adaptee->read( file => $path ) ) {
        my $class = $self->class;
        my $error = $adaptee->errstr;
        Carp::croak(qq/Failed to open '$path' using adaptor '$class'. Error: '$error'/);
    }

    return $self->new->adaptee($adaptee);
}

sub save {
    my ( $self, $path ) = @_;

    unless ( $self->adaptee->write( file => $path ) ) {
        my $class = $self->class;
        my $error = $self->adaptee->errstr;
        Carp::croak(qq/Failed to save '$path' using adaptor '$class'. Error: '$error'/);
    }

    return 1;
}

sub scale {
    my ( $self, $x, $y ) = @_;
    return $self->new->adaptee( $self->adaptee->scale( xpixels => $x, ypixels => $y ) );
}

sub crop {
    my ( $self, $x, $y, $w, $h ) = @_;
    return $self->new->adaptee( $self->adaptee->crop( left => $x, top => $y, width => $w, height => $h ) );
}

sub rotate {
    my ( $self, $angle ) = @_;
    return $self->adaptee( $self->adaptee->rotate( right => $angle ) );
}

sub width {
    my ( $self ) = @_;
    return $self->adaptee->getwidth;
}

sub height {
    my ( $self ) = @_;
    return $self->adaptee->getheight;
}

sub clone {
    my ( $self ) = @_;
    return $self->new->adaptee( $self->adaptee->copy );
}

1;

__END__

=head1 NAME

    Image::Simple::Imager - Adaptor for Imager

=head1 SYNOPSIS

    use Image::Simple;

    Image::Simple->adaptor('Imager');

    my $image = Image::Simple->open('/path/to/my/image.jpg');


=head1 DESCRIPTION

This class is not meant to be used directly.

=head1 METHODS

=over 4

=item new

=item adaptee

=item open( $file )

=item save( $file )

=item close

=item scale( $x, $y )

=item crop( $x, $y, $w, $h )

=item width

=item height

=item clone

=back

=head1 AUTHOR

Christian Hansen <ch@ngmedia.com>

=head1 SUPPORT

#catalyst on L<irc://irc.perl.org>

L<http://lists.rawmode.org/mailman/listinfo/catalyst>

L<http://lists.rawmode.org/mailman/listinfo/catalyst-dev>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Imager>

L<Image::Simple>

L<Image::Simple::Adapter>

L<Image::Simple::GD>

L<Image::Simple::GraphicsMagick>

L<Image::Simple::ImageMagick>

L<Image::Simple::Imlib2>

=cut