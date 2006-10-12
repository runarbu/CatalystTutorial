#!perl

use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 36;

use CGI::Catalyst::Test 'TestApp::Request';
use HTTP::Headers::Util 'split_header_words';
use HTTP::Request::Common;

{
    my $request = POST( 'http://localhost/',
        'Content-Type' => 'multipart/form-data',
        'Content'      => [
            'cookies.t' => [ "$FindBin::Bin/cookies.t" ],
            'headers.t' => [ "$FindBin::Bin/headers.t" ],
            'uploads.t' => [ "$FindBin::Bin/uploads.t" ],
         ]
    );

    my $app      = TestApp::Request->new;
    my $response = request( $request, $app );

    is( $app->request->method, 'POST', 'CGI::Catalyst::Request method' );
    is( $app->request->content_type, 'multipart/form-data', 'CGI::Catalyst::Request Content-Type' );
    is( $app->request->content_length, $request->content_length, 'CGI::Catalyst::Request Content-Length' );

    for my $part ( $request->parts ) {

        my $disposition = $part->header('Content-Disposition');
        my %parameters  = @{ ( split_header_words($disposition) )[0] };

        my $upload = $app->request->upload( $parameters{name} );

        isa_ok( $upload, 'CGI::Catalyst::Request::Upload' );
        is( $upload->filename, $parameters{filename}, 'Upload filename' );
        is( $upload->size, length( $part->content ), 'Upload Content-Length' );
        is( $upload->type, $part->content_type, 'Upload Content-Type' );
        is( $upload->slurp, $part->content, 'Upload slurp' );
    }
}

{
    my $request = POST( 'http://localhost/',
        'Content-Type' => 'multipart/form-data',
        'Content'      => [
            'testfile' => [ "$FindBin::Bin/cookies.t" ],
            'testfile' => [ "$FindBin::Bin/headers.t" ],
            'testfile' => [ "$FindBin::Bin/uploads.t" ],
         ]
    );

    my $app      = TestApp::Request->new;
    my $response = request( $request, $app );

    is( $app->request->method, 'POST', 'CGI::Catalyst::Request method' );
    is( $app->request->content_type, 'multipart/form-data', 'CGI::Catalyst::Request Content-Type' );
    is( $app->request->content_length, $request->content_length, 'CGI::Catalyst::Request Content-Length' );

    my @parts = $request->parts;

    for ( my $i = 0; $i < @parts; $i++ ) {

        my $part        = $parts[$i];
        my $disposition = $part->header('Content-Disposition');
        my %parameters  = @{ ( split_header_words($disposition) )[0] };

        my $upload = $app->request->uploads->{ $parameters{name} }->[$i];

        isa_ok( $upload, 'CGI::Catalyst::Request::Upload' );
        is( $upload->filename, $parameters{filename}, 'Upload filename' );
        is( $upload->size, length( $part->content ), 'Upload Content-Length' );
        is( $upload->type, $part->content_type, 'Upload Content-Type' );
        is( $upload->slurp, $part->content, 'Upload slurp' );
    }
}
