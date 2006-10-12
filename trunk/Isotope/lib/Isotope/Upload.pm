package Isotope::Upload;

use strict;
use warnings;
use base 'Isotope::Object';

use prefork 'File::Copy';
use prefork 'IO::File';

use Isotope::Exceptions qw[throw_io];
use Isotope::Headers    qw[];
use Moose               qw[has];

has 'headers'     => ( isa       => 'Isotope::Headers',
                       is        => 'rw',
                       coerce    => 1,
                       required  => 1,
                       default   => sub { Isotope::Headers->new } );

has 'filename'    => ( isa       => 'Str',
                       lazy      => 1,
                       default   => sub { $_[0]->parse_filename } );

has 'tempname'    => ( isa       => 'Str',
                       is        => 'rw' );

sub header {
    return shift->headers->header(@_);
}

sub has_header {
    return shift->headers->has(@_);
}

sub content_length {
    return shift->headers->content_length(@_);
}

sub content_type {
    return shift->headers->content_type(@_);
}

sub fh {
    my $self = shift;
    my $path = $self->tempname;
    
    require IO::File;

    my $fh = IO::File->new( $path, &IO::File::O_RDONLY )
      or throw_io message => qq/Could not open upload '$path' in read only mode./,
                  payload => $!;

    return $fh;
}

sub copy_to {
    my $self   = shift;
    my $target = shift;
    my $source = $self->tempname;
    
    require File::Copy;
    
    return File::Copy::copy( $source, $target )
      or throw_io message => qq/Could not copy upload '$source' to '$target'./,
                  payload => $!;
}

sub link_to {
    my ( $self, $target ) = @_;
    return link( $self->tempname, $target );
}

sub slurp {
    my ( $self, $layer ) = @_;

    my $fh = $self->fh;

    binmode( $fh, $layer ? $layer : () )
      or throw_io message => qq/Could not binmode upload handle./,
                  payload => $!;

    # XXX use File::Slurp instead?
    return do { local $/ = undef; $fh->getline };
}

sub parse_filename {
    my $self = shift;
    
    if ( $self->has_header('Content-Disposition') ) {
        
        if ( $self->header('Content-Disposition') =~ / filename="([^;]*)"/ ) {
            return $1;
        }
    }

    return undef;
}

1;
