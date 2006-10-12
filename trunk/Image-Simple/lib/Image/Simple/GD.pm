package Image::Simple::GD;

use strict;
use base 'Image::Simple::Adaptor';

use GD;
use IO::File;

sub open {
    my ( $self, $path ) = @_;

    my $adaptee;

    unless ( $adaptee = GD::Image->new($path) ) {
        my $class = $self->class;
        Carp::croak(qq/Failed to open '$path' using adaptor '$class'. Error: '$!'/);
    }

    return $self->new->adaptee($adaptee);
}

sub save {
    my ( $self, $path ) = @_;

    my $handle = IO::File->new( $path, O_WRONLY | O_CREAT | O_TRUNC );
    $handle->syswrite( $self->adaptee->jpeg(100) );
    $handle->close;

    return 1;
}

sub scale {
    my ( $self, $x, $y ) = @_;

    my $scale = GD::Image->new( $x, $y, $self->adaptee->isTrueColor ? 1 : 0 );
    $scale->copyResized( $self->adaptee, 0, 0, 0, 0, $x, $y, $self->width, $self->height );

    return $self->new->adaptee($scale);
}

sub crop {
    my ( $self, $x, $y, $w, $h ) = @_;

    my $crop = GD::Image->new( $x, $y, $self->adaptee->isTrueColor ? 1 : 0 );
    $crop->copyResized( $self->adaptee, 0, 0, $x, $y, $w, $h, $w, $h );

    return $self->new->adaptee($crop);
}

sub rotate {
    my ( $self, $angle ) = @_;
    
    if ( $angle == 90 ) {
        $self->adaptee( $self->adaptee->copyRotate90 );
    }
    
    if ( $angle == 180 ) {
        $self->adaptee( $self->adaptee->copyRotate180 );
    }

    if ( $angle == 270 ) {
        $self->adaptee( $self->adaptee->copyRotate270 );
    }
    
    return 1;
}

sub width {
    my ( $self ) = @_;
    return $self->adaptee->width;
}

sub height {
    my ( $self ) = @_;
    return $self->adaptee->height;
}

sub clone {
    my ( $self ) = @_;
    return $self->new->adaptee( $self->adaptee->clone );
}

1;

__END__

=head1 NAME

    Image::Simple::GD - Adaptor for GD

=head1 SYNOPSIS

    use Image::Simple;

    Image::Simple->adaptor('GD');

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

L<GD>

L<Image::Simple>

L<Image::Simple::Adapter>

L<Image::Simple::GraphicsMagick>

L<Image::Simple::ImageMagick>

L<Image::Simple::Imager>

L<Image::Simple::Imlib2>

=cut