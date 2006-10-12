package Streaming;

# This example application demos simple streaming support in Catalyst
# by streaming an mp3 file to a media player.  You will need to point the MP3
# variable to an mp3 file.  Then access http://localhost:3000/mp3 in your
# favorite mp3 player.
#
# Works with:
# HTTP server
# CGI
# FastCGI
# Apache
#
# Known issues: 
# When the client disconnects under FastCGI, the process appears to get killed
# instead of being allowed to clean up.
#

use strict;
use Catalyst qw/-Debug/;
use File::Basename;
use MP3::Info;

our $VERSION = '0.01';

# change this
our $MP3 = '/home/andy/dev/Catalyst/examples/Streaming/test.mp3';

Streaming->config( name => 'Streaming' );

Streaming->setup;

sub default : Private {
    my ( $self, $c ) = @_;
    
    $c->res->output( 'Access /mp3 to run the demo' );
}

sub mp3 : Local {
    my ( $self, $c ) = @_;
    
    my $size = (stat( $MP3 ))[7];
    my $basename = basename( $MP3 );
    
    # note that headers are sent automatically as soon as we access the 
    # response handle via $c->res->handle, so we don't have to send them
    # manually
    $c->res->content_type( 'audio/mpeg-3' );
    $c->res->content_length( $size );
    $c->res->header( 'Content-Disposition' => 'filename=' . $basename );
    $c->res->header( 'Accept-Ranges' => 'bytes' );
    
    # support seeking in mp3 file
    my $offset = 0;
    if ( my $range = $c->req->header( 'Range' ) ) {
        $range =~ m/bytes=(\d+)-/xms;
        $offset = $1;
        warn "Got Range request, seeking to $offset\n";
        
        if ( $offset < $size ) {
            $c->res->status( 206 );
            $c->res->header( 'Content-Ranges' => "bytes $offset-$size/$size" );
        }
        else {
            $offset = 0;
        }
    }
    
    open my $fh, '<', $MP3 || die "Unable to open $MP3 for reading";
    binmode $fh;
    
    if ( seek $fh, $offset, 0 ) {
        # write chunks at mp3 bitrate + 1K
        my $info = get_mp3info( $MP3 );
        my $bitrate = $info->{BITRATE};
        my $bytes = ( ($bitrate / 8) * 1024 ) + 1024;
        
        STREAM:
        while ( read( $fh, my $buffer, $bytes ) ) {
            warn "Writing " . length($buffer) . " bytes to client\n";
            
            # write until the client drops connection
            last STREAM unless $c->write( $buffer );
        }
    }

    warn "Closing file and finishing up\n";
    close $fh;
}

1;
