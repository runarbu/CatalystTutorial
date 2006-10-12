#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
BEGIN {
    eval { require Test::WWW::Mechanize::Catalyst }
      or plan skip_all =>
      "Test::WWW::Mechanize::Catalyst is needed for this test";
    eval { require Catalyst::Plugin::Cache::FileCache }
      or plan skip_all =>
      "Catalyst::Plugin::Cache::FileCache is needed for this test";
    plan tests => 4;
}
use HTTP::Request;
{
    package AuthTestApp;
    use Catalyst qw/
      Authentication
      Authentication::Store::Minimal
      Authentication::Credential::HTTP
      Cache::FileCache
      /;
    use Test::More;
    our $users;
    sub moose : Local {
        my ( $self, $c ) = @_;
        $c->authorization_required( realm => 'testrealm@host.com' );
        $c->res->body( $c->user->id );
    }
    __PACKAGE__->config->{authentication}{http}{type} = 'digest';
    __PACKAGE__->config->{authentication}{users} = $users = {
        Mufasa => { password         => "Circle Of Life", },
    };
    __PACKAGE__->setup;
}
use Test::WWW::Mechanize::Catalyst qw/AuthTestApp/;
my $mech = Test::WWW::Mechanize::Catalyst->new;
$mech->get("http://localhost/moose");
is( $mech->status, 401, "status is 401" );
my $www_auth = $mech->res->headers->header('WWW-Authenticate');
my %www_auth_params = map {
    my @key_val = split /=/, $_, 2;
    $key_val[0] = lc $key_val[0];
    $key_val[1] =~ s{"}{}g;    # remove the quotes
    @key_val;
} split /, /, substr( $www_auth, 7 );    #7 == length "Digest "
$mech->content_lacks( "foo", "no output" );
my $response = '';
{
    my $username = 'Mufasa';
    my $password = 'Circle Of Life';
    my $realm    = $www_auth_params{realm};
    my $nonce    = $www_auth_params{nonce};
    my $cnonce   = '0a4f113b';
    my $opaque   = $www_auth_params{opaque};
    my $nc       = '00000001';
    my $method   = 'GET';
    my $qop      = 'auth';
    my $uri      = '/moose';
    my $ctx = Digest::MD5->new;
    $ctx->add( join( ':', $username, $realm, $password ) );
    my $A1_digest = $ctx->hexdigest;
    $ctx = Digest::MD5->new;
    $ctx->add( join( ':', $method, $uri ) );
    my $A2_digest = $ctx->hexdigest;
    my $digest = Digest::MD5::md5_hex(
        join( ':',
            $A1_digest, $nonce, $qop ? ( $nc, $cnonce, $qop ) : (), $A2_digest )
    );

    $response = qq{Digest username="$username", realm="$realm", nonce="$nonce", uri="$uri", qop=$qop, nc=$nc, cnonce="$cnonce", response="$digest", opaque="$opaque"};
}
my $r = HTTP::Request->new( GET => "http://localhost/moose" );
$mech->request($r);
$r->headers->push_header( Authorization => $response );
$mech->request($r);
is( $mech->status, 200, "status is 200" );
$mech->content_contains( "Mufasa", "Mufasa output" );
