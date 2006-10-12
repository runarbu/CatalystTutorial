#!/usr/bin/perl

use strict;
use warnings;

use lib "t/lib";

use Test::More;

BEGIN {
    eval {
        require Catalyst::Plugin::Session::State::Cookie;
        Catalyst::Plugin::Session::State::Cookie->VERSION(0.03);
    } or plan skip_all => "Catalyst::Plugin::Session::State::Cookie 0.03 or higher is required for this test";
    
    eval { require Test::WWW::Mechanize::Catalyst }
        or plan skip_all => "Test::WWW::Mechanize::Catalyst is required for this test";

    plan tests => 32;
}

use Test::WWW::Mechanize::Catalyst "RewritingTestApp";

foreach my $use_cookies (1, 0) {
    my $m = Test::WWW::Mechanize::Catalyst->new( $use_cookies ? () : ( cookie_jar => undef ) );

    $m->get_ok( "http://localhost/first_request", "initial request" );

    $m->content_like( qr/counter: 1\b/, "counter at 1" );

    my $second = $m->find_link( text => "second");

    # the first request *always* gets rewritten links because we don't know if the UA supports cookies yet
    like( $second->URI, qr{/-/}, "uri was rewritten for first request" );

    $m->follow_link_ok( { text => "second" }, "go to second page" );

    $m->content_like( qr/counter: 2\b/, "counter at 2" );

    my $third = $m->find_link( text => "third" );

    if ( $use_cookies) {
        unlike( $third->URI, qr{/-/}, "uri has not been rewritten because a cookie was sent" );
    } else {
        like( $third->URI, qr{/-/}, "uri was rewritten" );
    }
    
    $m->follow_link_ok( { text => "third" }, "go to third page" );

    $m->content_like( qr/counter: 3\b/, "counter at 3" );

}

{
    my $m = Test::WWW::Mechanize::Catalyst->new( cookie_jar => undef );

    $m->get_ok("http://localhost/text_request?plain=0", "get text req as non plaintext");
    $m->content_like( qr/counter: 42\b/, "counter in body" );
    $m->content_like( qr{/-/}, "body rewritten" );

    $m->get_ok("http://localhost/text_request?plain=1", "get text req as plain text");
    $m->content_like( qr/counter: 42\b/, "counter in body" );
    $m->content_unlike( qr{/-/}, "body not rewritten because of wrong content type" );
}
