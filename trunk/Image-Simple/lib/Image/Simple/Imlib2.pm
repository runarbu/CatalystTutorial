package Image::Simple::Imlib2;

use strict;
use base 'Image::Simple::Adaptor';

use Carp ();
use Image::Imlib2 1.07;

sub open {
    my ( $self, $path ) = @_;

    my $adaptee;

    eval {
        $adaptee = Image::Imlib2->load($path);
    };

    if ( my $error = $@ ) {
        my $class = $self->class;
        Carp::croak(qq/Failed to open '$path' using adaptor '$class'. Error: '$error'/);
    }

    return $self->new->adaptee($adaptee);
}

sub save {
    my ( $self, $path ) = @_;

    eval {
        $self->adaptee->save($path);
    };

    if ( my $error = $@ ) {
        my $class = $self->class;
        Carp::croak(qq/Failed to save '$path' using adaptor '$class'. Error: '$error'/);
    }

    return 1;
}

sub scale {
    my ( $self, $x, $y ) = @_;
    return $self->new->adaptee( $self->adaptee->create_scaled_image( $x, $y ) );
}

sub crop {
    my ( $self, $x, $y, $w, $h ) = @_;
    return $self->new->adaptee( $self->adaptee->crop( $x, $y, $w, $h ) );
}

sub rotate {
    my ( $self, $angle ) = @_;
    return $self->adaptee->image_orientate( $angle / 90 );
}

sub width {
    my ( $self ) = @_;
    return $self->adaptee->get_width;
}

sub height {
    my ( $self ) = @_;
    return $self->adaptee->get_height;
}

sub clone {
    my ( $self ) = @_;
    return $self->new->adaptee( $self->adaptee->clone );
}

1;


__END__

=head1 NAME

    Image::Simple::Imlib2 - Adaptor for Image::Imlib2

=head1 SYNOPSIS

    use Image::Simple;

    Image::Simple->adaptor('Imlib2');

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

L<Image::Simple::Imager>

=cut
