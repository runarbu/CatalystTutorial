package PerlIOBody;

use strict;
use base qw(IO::Handle IO::Seekable Exporter);
use overload '""' => \&content, fallback => 1;

use IO::Seekable;
use PerlIO qw(scalar encoding);

our @EXPORT = @IO::Seekable::EXPORT;

sub new {
    my $class    = shift;
    my $encoding = shift || 'UTF-8';

    my $self = $class->SUPER::new;
    ${*$self}{'scalar'}   = '';
    ${*$self}{'encoding'} = $encoding;

    my $mode = sprintf( "+<:scalar:encoding(%s)", $encoding );

    open( $self, $mode, \${*$self}{scalar} )
      or return die( "Failed to open PerlIO scalar: $!" );

    return $self;
}

sub encoding {
    my $self = shift;
    return ${*$self}{encoding};
}

sub length {
    my $self = shift;
    $self->seek( 0, SEEK_END );
    return $self->tell;
}

sub content {
    my $self = shift;
    $self->seek( 0, SEEK_SET );
    return ${*$self}{scalar};
}

1;
