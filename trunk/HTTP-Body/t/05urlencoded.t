#!perl

use strict;
use warnings;

use Test::More tests => 5;

use Cwd;
use HTTP::Body;
use File::Spec::Functions;
use IO::File;
use YAML;

my $path = catdir( getcwd(), 't', 'data', 'urlencoded' );

for ( my $i = 1; $i <= 1; $i++ ) {

    my $test    = sprintf( "%.3d", $i );
    my $headers = YAML::LoadFile( catfile( $path, "$test-headers.yml" ) );
    my $results = YAML::LoadFile( catfile( $path, "$test-results.yml" ) );
    my $content = IO::File->new( catfile( $path, "$test-content.dat" ) );
    my $body    = HTTP::Body->new( $headers->{'Content-Type'}, $headers->{'Content-Length'} );

    binmode $content, ':raw';

    while ( $content->read( my $buffer, 1024 ) ) {
        $body->add($buffer);
    }

    is_deeply( $body->body, $results->{body}, "$test UrlEncoded body" );
    is_deeply( $body->param, $results->{param}, "$test UrlEncoded param" );
    is_deeply( $body->upload, $results->{upload}, "$test UrlEncoded upload" );
    cmp_ok( $body->state, 'eq', 'done', "$test UrlEncoded state" );
    cmp_ok( $body->length, '==', $headers->{'Content-Length'}, "$test UrlEncoded length" );
}
