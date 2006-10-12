package Image::Simple::ImageMagick;

use strict;
use base 'Image::Simple::Adaptor';

use Carp ();
use Image::Magick;

sub open {
    my ( $self, $path ) = @_;

    my $adaptee = Image::Magick->new;

    if ( my $error = $adaptee->Read($path) ) {
        my $class = $self->class;
        Carp::croak(qq/Failed to open '$path' using adaptor '$class'. Error: '$error'/);
    }

    return $self->new->adaptee($adaptee);
}

sub save {
    my ( $self, $path ) = @_;

    if ( my $error = $self->adaptee->Write($path) ) {
        my $class = $self->class;
        Carp::croak(qq/Failed to save '$path' using adaptor '$class'. Error: '$error'/);
    }

    return 1;
}

sub scale {
    my ( $self, $x, $y ) = @_;

    my $scale = $self->clone;
    $scale->adaptee->Scale( width => $x, height => $y );

    return $scale;
}

sub crop {
    my ( $self, $x, $y, $w, $h ) = @_;

    my $crop = $self->clone;
    $crop->adaptee->Crop( x => $x, y => $y, width => $w, height => $h );

    return $crop;
}

sub rotate {
    my ( $self, $angle ) = @_;
    return $self->adaptee->Rotate( degrees => $angle );
}

sub width {
    my ( $self ) = @_;
    return $self->adaptee->Get('width');
}

sub height {
    my ( $self ) = @_;
    return $self->adaptee->Get('height');
}

sub clone {
    my ( $self ) = @_;
    return $self->new->adaptee( $self->adaptee->Clone );
}

1;

__END__

=head1 NAME

    Image::Simple::ImageMagick - Adaptor for Image::Magick

=head1 SYNOPSIS

    use Image::Simple;

    Image::Simple->adaptor('ImageMagick');

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

L<Graphics::Magick>

L<Image::Simple>

L<Image::Simple::Adapter>

L<Image::Simple::GD>

L<Image::Simple::GraphicsMagick>

L<Image::Simple::Imager>

L<Image::Simple::Imlib2>

=cut
