#!perl

use strict;
use warnings;

BEGIN {
    use FindBin;
    use lib "$FindBin::Bin/dispatch/lib";
    
    chdir 't' if -d 't';
    use lib qw[../lib inc];

    require 'local_request.pl';
}

use Test::More  'no_plan';
use Catalyst::Test 'TestApp';

use RPC::XML;
use HTTP::Request;
use Data::Dumper;

my $EntryPoint  = 'http://localhost/rpc';
my @Methods     = qw[a 1];
    

# init -- mention var twice due to warnings;
$RPC::XML::ENCODING = $RPC::XML::ENCODING = 'UTF-8';

for my $meth ( @Methods ) {

    my $str = RPC::XML::request->new( $meth )->as_string;

    my $req = HTTP::Request->new( POST => $EntryPoint );
    $req->header( 'Content-Length'  => length($str) );
    $req->header( 'Content-Type'    => 'text/xml' );
    $req->content( $str );
    my $res = request( $req );
    
    ok( $res,                   "Got response on '$meth'" );
    ok( $res->is_success,       "   Response successfull 2XX" );
    is( $res->code, 200,        "   Reponse code 200" );
    
    my $data = RPC::XML::Parser->new->parse( $res->content )->value->value;
    is_deeply( $data, $meth,    "   Return value as expected" );

    if( ref $data and UNIVERSAL::isa( $data, 'HASH' ) ) {
        ok( not(exists($data->{faultString})),
                                "   No faultstring" );
        ok( not(exists($data->{faultCode})),
                                "   No faultcode" );
        
        diag( $data->{faultCode} . ' ' . $data->{faultString} )
            if $data->{faultString};
    }
}
