package Isotope::Dispatcher::Static;

use strict;
use warnings;
use base 'Isotope::Dispatcher';

use prefork 'File::MMagic::XS';     # Does this work on Win32?
use prefork 'File::MMagic::compat';
use prefork 'File::stat';
use prefork 'IO::File';

use File::Spec          qw[];
use File::Spec::Unix    qw[];
use Isotope::Exceptions qw[throw_dispatcher];
use Moose               qw[has];

has 'root'    => ( isa       => 'Str',
                   is        => 'rw',
                   required  => 1 );

has 'index'   => ( isa       => 'ArrayRef',
                   is        => 'ro',
                   predicate => 'has_index' );

has 'expires' => ( isa       => 'Int',
                   is        => 'ro',
                   required  => 1,
                   default   => 0 );

has 'mmagic'  => ( isa       => 'Object',
                   is        => 'ro',
                   lazy      => 1,
                   required  => 1,
                   default   => sub { $_[0]->construct_mmagic; } );

sub BUILD {
    my ( $self, $params ) = @_;

    my $root = $params->{root};

    unless ( File::Spec->file_name_is_absolute($root) ) {
        $root = File::Spec->rel2abs($root);
    }

    throw_dispatcher message => qq/Dispatcher root '$root' does not exist./,
                     payload => $!
      unless -e $root;

    throw_dispatcher message => qq/Dispatcher root '$root' is not a directory./,
                     payload => $!
      unless -d _;

    throw_dispatcher message => qq/Dispatcher root '$root' is not readable by effective uid '$>'./,
                     payload => $!
      unless -r _;

    $self->root($root);
}

sub construct_mmagic {
    my $self = shift;

    unless ( $INC{'File/MMagic/compat.pm'} ) {
        require File::MMagic::XS;
        require File::MMagic::compat;
    }

    return File::MMagic::XS->new;
}

sub dispatch {
    my ( $self, $transaction, $base ) = @_;

    my $path   = $self->translate_path( $transaction, $base );
    my $method = $transaction->request->method;

    throw_dispatcher message => qq/Local path '$path' does not exist./,
                     status  => 404
      unless -e $path;

    throw_dispatcher message => qq/Local path '$path' is neither a plain file or a directory./,
                     status  => 404
      unless ( -f _ || -d _ );

    throw_dispatcher message => qq/Local path '$path' is not readable by effective uid '$>'./,
                     status  => 403
      unless -r _;

    throw_dispatcher message => qq/The requested method '$method' is not allowed./,
                     status  => 405,
                     headers => { Allow => 'GET, HEAD' }
      unless $method =~ /^GET|HEAD$/;

    require File::stat;

    my $stat = File::stat::populate( stat(_) );

    if ( -d _ ) {
        return $self->serve_directory( $transaction, $path, $stat );
    }

    if ( -f _ ) {
        return $self->serve_file( $transaction, $path, $stat );
    }
}

sub translate_path {
    my ( $self, $t, $path ) = @_;
    return File::Spec->catfile( $self->root, File::Spec::Unix->splitdir($path) );
}

sub serve_directory {
    my ( $self, $t, $path, $stat ) = @_;
    
    if ( substr( $t->request->uri->path, -1 ) ne '/' ) {
        $t->response->redirect( $t->request->uri->path . '/' );
        return;
    }

    if ( $self->has_index ) {

        foreach my $index ( @{ $self->index } ) {

            my $file = File::Spec->catfile( $path, $index );

            next unless -e $file && -f _ && -r _;

            my $stat = File::stat::populate( stat(_) );

            return $self->serve_file( $t, $file, $stat );
        }
    }

    throw_dispatcher message => qq/Local path '$path' is a directory./,
                     status  => 404;
}

sub serve_file {
    my ( $self, $t, $path, $stat ) = @_;

    my $etag = $self->make_etag( $t, $path, $stat );

    $t->response->etag($etag);

    if ( $self->expires > 0 ) {
        $t->response->expires( time() + $self->expires );
        $t->response->header( 'Cache-Control' => sprintf( "max-age=%d", $self->expires ) );
    }

    if ( $self->is_not_modified( $t, $etag, $stat ) ) {
        $t->response->status(304);
        return;
    }

    my $type   = $self->make_content_type( $t, $path, $stat );
    my $length = $stat->size;

=begin XXX

    my ( $start, $end ) = ( 0, 0 );

    if ( $t->request->has_header('Range') ) {

        if ( my @sets = $self->parse_bytes_range( $t, $path, $stat ) ) {
            
            $start  = $sets[0]->[0];
            $end    = $sets[0]->[1];
            $length = $end - $start;

            $t->response->header(
                'Content-Range' => sprintf( 'bytes %d-%d/%d', $start, $end - 1, $length )
            );
        }
    }

=cut

    $t->response->content_type($type);
    $t->response->content_length( $length );
    $t->response->last_modified( $stat->mtime );


    if ( $t->request->method eq 'HEAD' ) {
        return;
    }

    # XXX PerlIO::subfile for range set

    require IO::File;

    my $handle = IO::File->new( $path, &IO::File::O_RDONLY )
      or throw_dispatcher message => qq/Could not open file '$path' in readonly mode./,
                          payload => $!,
                          status  => 500;

    binmode( $handle )
      or throw_dispatcher message => qq/Could not binmode file '$path'./,
                          payload => $!,
                          status  => 500;

    $t->response->content($handle);
}

sub make_etag {
    my ( $self, $t, $path, $stat ) = @_;

    # play safe, if path has changed within 5 seconds generate a weak etag
    if ( $stat->mtime >= ( time() - 5 ) ) {
        return sprintf 'W/"%x-%x-%x"', $stat->ino, $stat->mtime, $stat->size;
    }
    else {
        return sprintf '"%x-%x-%x"', $stat->ino, $stat->mtime, $stat->size;
    }
}

sub make_content_type {
    my ( $self, $t, $path, $stat ) = @_;

    return $self->mmagic->checktype_filename($path)
      or throw_dispatcher message => qq/Could not check mime type for path '$path'./,
                          payload => $self->mmagic->error,
                          status  => 500;
}

sub is_not_modified {
    my ( $self, $t, $etag, $stat ) = @_;

    if (    $t->request->has_header('If-Range')
         && $t->request->has_header('Range') ) {

        foreach my $if ( $t->request->headers->if_range ) {

            if ( $if =~ /^\d+$/ ) {
                return 1 if $if >= $stat->mtime;
            }
            else {
                return 1 if $if eq $etag;
            }
        }

        return 0;
    }

    if ( $t->request->has_header('If-None-Match') ) {

        foreach my $if ( $t->request->headers->if_none_match ) {

            if ( $if eq '*' ) {
                return 1;
            }
            else {
                return 1 if ( $if eq $etag || $if eq "W/$etag" );
            }
        }

        return 0;
    }

    if ( $t->request->has_header('If-Modified-Since') ) {

        if ( my $since = $t->request->headers->if_modified_since ) {
            return 1 if $since >= $stat->mtime;
        }

        return 0;
    }

    return 0;
}

sub parse_bytes_range {
    my ( $self, $t, $path, $stat ) = @_;

    unless ( $t->request->header('Range') =~ /^bytes=(.*)$/ ) {
        return ();
    }

    my $range = $1;
    my $size  = $stat->size;
    my @sets  = ();

    # RFC 2616 14.35.1 Byte Ranges
    # http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.35

    foreach ( split( /,/, $range ) ) {

        my ( $first, $last );

        if ( /^(\d+)-(\d+)$/ ) {
            ( $first, $last ) = ( $1, $2 >= $size ? $size : $2 + 1 );

            # If the last-byte-pos value is present, it MUST be greater than or
            # equal to the first-byte-pos in that byte-range-spec, or the byte-
            # range-spec is syntactically invalid. The recipient of a byte-range-
            # set that includes one or more syntactically invalid byte-range-spec
            # values MUST ignore the header field that includes that byte-range-
            # set.
            return () if $2 < $1;
        }
        elsif ( /^(\d+)-$/ ) {
            ( $first, $last ) = ( $1, $size );
        }
        elsif ( /^-(\d+)$/ ) {
            ( $first, $last ) = ( $size - $1, $size );

            # If suffix-length is greater than entity length we ignore range header
            # since we have to serve entire entity-body
            return () if $first <= 0;
        }
        else {
            # If it didn't match it's syntactically invalid.
            return ();
        }

        if ( $first >= 0 && $first < $size && $last > 0 && $last > $first ) {
            push @sets, [ $first, $last ];
        }
    }

    return @sets if @sets;

    throw_dispatcher message => qq/Requested range '$range' was not satisfiable./,
                     status  => 416,
                     headers => { 'Content-Range' => "bytes */$size" };
}

1;
