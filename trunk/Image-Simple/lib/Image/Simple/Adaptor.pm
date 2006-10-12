package Image::Simple::Adaptor;

use strict;
use Carp ();

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    unless ( @_ == 0 ) {
        Carp::croak(qq/usage: $class->new()/);
    }

    return bless( {}, $class );
}

sub adaptee {
    my $self = shift;

    if ( my $adaptee = shift ) {

        unless ( ref($adaptee) ) {
            Carp::croak( qq/Argument '$adaptee' is not an object/ );
        }

        $self->{adaptee} = $adaptee;
        return $self;
    }

    return $self->{adaptee};
}

sub class {
    return ref($_[0]) || $_[0];
}

sub open {
    Carp::croak( __PACKAGE__ . qq/->open is an abstract method/ );
}

sub save {
    Carp::croak( __PACKAGE__ . qq/->save is an abstract method/ );
}

sub close {
    Carp::croak( __PACKAGE__ . qq/->close is an abstract method/ );
}

sub crop {
    Carp::croak( __PACKAGE__ . qq/->crop is an abstract method/ );
}

sub scale {
    Carp::croak( __PACKAGE__ . qq/->scale is an abstract method/ );
}

sub rotate {
    Carp::croak( __PACKAGE__ . qq/->rotate is an abstract method/ );
}

sub clone {
    Carp::croak( __PACKAGE__ . qq/->clone is an abstract method/ );
}

sub width {
    Carp::croak( __PACKAGE__ . qq/->width is an abstract method/ );
}

sub height {
    Carp::croak( __PACKAGE__ . qq/->height is an abstract method/ );
}

1;

__END__

=head1 NAME

    Image::Simple::Adaptor - Base class for adaptors

=head1 SYNOPSIS

    package Image::Simple::MyAdaptor;
    
    sub open {
        
    }


=head1 DESCRIPTION

This class is not meant to be used directly.

=head1 METHODS

=over 4

=item new

=item adaptee

=item class

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

L<Image::Simple>

L<Image::Simple::GD>

L<Image::Simple::GraphicsMagick>

L<Image::Simple::ImageMagick>

L<Image::Simple::Imager>

L<Image::Simple::Imlib2>

=cut
