#!/usr/bin/perl
use warnings;
use strict;

use Test::More;

my $lighttpd_path;
my $lighttpd_pid;
eval { $lighttpd_path = $ENV{LIGHTTPD_PATH}
   } or plan skip_all => "don't know where lighttpd is, please pass the location of lighttpd binary to this script as environment varialbe LIGHTTPD_PATH";

eval { require Test::WWW::Mechanize }
    or plan skip_all =>
    'Test::WWW::Mechanize is required for this test';

eval {
    use File::Temp qw/tempfile/;
    use FindBin qw($Bin);
    use Path::Class;
    my $fcgi_script = "$Bin/lib/FcgiTest/script/fcgitest_fastcgi.pl";
    #        my $fcgi_script = Path::Class->dir($Bin)->subdir('lib')->subdir('FcgiTest')->subdir('script')->file('fcgitest_fastcgi.pl');
    my ($socket_fh, $socket) = tempfile();
    my ($alog_fh, $alog_f) = tempfile(); # access log
    my ($elog_fh, $elog_f) = tempfile(); # error log
    my ($conf_fh, $conf_f) = tempfile(); # lighttpd config
    my $config = <<EOF;
# basic lighttpd config file for testing fcgi+catalyst
server.modules              = (
                                "mod_access",
                               "mod_fastcgi",
                                "mod_accesslog" )
server.document-root        = "/tmp"
server.errorlog             = "$elog_f"
index-file.names            = ( "index.php", "index.html",
                                "index.htm", "default.htm" )
accesslog.filename          = "$alog_f"
server.port                = 9999
# catalyst app specific fcgi setup
fastcgi.server = (
               "" => (
                   "FastCgiTest" => (
                       "socket"       => "$socket",
                       "check-local"  => "disable",
                       "bin-path"     => "$fcgi_script",
                       "min-procs"    => 1,
                       "max-procs"    => 1,
                       "idle-timeout" => 20
                   )
               )
           )
EOF
    print $conf_fh $config;
    if ( $lighttpd_pid = fork) {
        exec "$lighttpd_path -D -f $conf_f 2>/dev/null &" or die "problem forking lighttpd";
    }

};
if ($@ ne '' ) {
    plan skip_all => "Unable to  lighttpd config with error: $@";
}

my $ua = Test::WWW::Mechanize->new;
my $server = "http://localhost:9999";

require "$Bin/run/01-behaviour-tests.tl";
run_tests($server, $ua);

END {
    system "kill $lighttpd_pid 2>&1/dev/null";
}
