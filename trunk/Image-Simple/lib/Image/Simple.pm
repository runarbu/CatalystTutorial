package Image::Simple;

use strict;

use Carp ();
use Image::Math::Constrain;

our $VERSION = '0.01';
our $ADAPTOR = undef;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    unless ( @_ == 0 ) {
        Carp::croak(qq/usage: $class->new()/);
    }

    return bless( {}, $class );
}

sub adaptor {
    my $self = shift;

    if ( my $adaptor = shift ) {

        unless ( ref($adaptor) ) {

            $adaptor = "Image::Simple::$adaptor";

            eval "require $adaptor";

            if ( my $error = $@ ) {
                Carp::croak(qq/Failed to require adaptor '$adaptor' : '$error'/);
            }
        }

        unless ( ref($self) ) {
            return $ADAPTOR = $adaptor;
        }

        $self->{adaptor} = $adaptor;
        return $self;
    }

    unless ( ref($self) ) {

        unless ( defined $ADAPTOR ) {
            Carp::croak(qq/Image::Simple->adaptor is not set/);
        }

        return $ADAPTOR;
    }

    return $self->{adaptor};
}

sub open {
    my ( $self, $file ) = @_;

    unless ( @_ == 2 ) {
        Carp::croak('usage: $image->open($file)');
    }

    unless ( -e $file ) {
        Carp::croak(qq/File '$file' does not exists/);
    }

    unless ( -f _ ) {
        Carp::croak(qq/File '$file' is not a plain file/);
    }

    unless ( -r _ ) {
        Carp::croak(qq/File '$file' is not readable by effective uid\/gid/);
    }

    return $self->new->adaptor( $self->adaptor->open($file) );
}

sub close {
    my ( $self ) = @_;

    unless ( @_ == 1 ) {
        Carp::croak('usage: $image->close()');
    }

    $self->DESTROY;
}

sub save {
    my ( $self, $file ) = @_;

    unless ( @_ == 2 ) {
        Carp::croak('usage: $image->save($file)');
    }

    unless ( !-e $file || -w _ ) {
        Carp::croak(qq/File '$file' is not writable by effective uid\/gid/);
    }

    $self->adaptor->save($file);
    
    return $self;
}

sub scale {
    my ( $self, $x, $y ) = @_;

    unless ( @_ == 3 ) {
        Carp::croak('usage: $image->crop( $x, $y )');
    }

    return $self->new->adaptor( $self->adaptor->scale( $self->_constrain( $x, $y ) ) );
}

sub crop {
    my ( $self, $x, $y, $w, $h ) = @_;

    unless ( @_ == 5 ) {
        Carp::croak('usage: $image->crop( $x, $y, $w, $h )');
    }

    return $self->new->adaptor( $self->adaptor->crop( $x, $y, $w, $h ) );
}

sub rotate {
    my ( $self, $angle ) = @_;

    unless ( @_ == 2 ) {
        Carp::croak('usage: $image->rotate( $angle )');
    }
    
    unless ( $angle =~ /^(90|180|270)$/ ) {
        Carp::croak('$image->rotate( 90 | 180 | 270 )');
    }
    
    $self->adaptor->rotate($angle);
    
    return $self;
}

sub width {
    my ($self) = @_;

    unless ( @_ == 1 ) {
        Carp::croak('usage: $image->width()');
    }

    return $self->adaptor->width;
}

sub height {
    my ($self) = @_;

    unless ( @_ == 1 ) {
        Carp::croak('usage: $image->height()');
    }

    return $self->adaptor->height;
}

sub clone {
    my ($self) = @_;

    unless ( @_ == 1 ) {
        Carp::croak('usage: $image->clone()');
    }

    return $self->new->adaptor( $self->adaptor->clone );
}

sub _constrain {
    my ( $self, $x, $y ) = @_;
    my $math = Image::Math::Constrain->new( $x, $y );
    return ( $math->constrain( $self->width, $self->height ) )[ 0, 1 ];
}

1;

__END__

=head1 NAME

    Image::Simple - Simple API for simple imaging

=head1 SYNOPSIS

    use Image::Simple;

    Image::Simple->adaptor('Imlib2');

    my $image = Image::Simple->open('/path/to/my/image.jpg');

    printf( "width  : %d", $image->width );
    printf( "height : %d", $image->height );

    my $scale = $image->scale( 150, 0 );
    $scale->save('./scale.jpg');

    my $crop = $scale->crop( 10, 10, 10, 10 );
    $crop->save('./crop.jpg');


=head1 DESCRIPTION

=head1 METHODS

=over 4

=item new

=item adaptor

=item open( $file )

=item close

=item save( $file )

=item scale( $x, $y )

=item crop( $x, $y, $w, $h )

=item rotate( $angle )

=item width

=item height

=item clone

=back

=head1 ADAPTORS

L<Image::Simple::GD>

L<Image::Simple::GraphicsMagick>

L<Image::Simple::ImageMagick>

L<Image::Simple::Imager>

L<Image::Simple::Imlib2>

=head1 AUTHOR

Christian Hansen <ch@ngmedia.com>

=head1 SUPPORT

#catalyst on L<irc://irc.perl.org>

L<http://lists.rawmode.org/mailman/listinfo/catalyst>

L<http://lists.rawmode.org/mailman/listinfo/catalyst-dev>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
