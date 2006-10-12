use strict;
use warnings;
use File::Copy 'copy';
use File::Find;
use File::Spec;
use lib 'lib';
use HTML::Dojo ':no_files';

if (! @ARGV) {
    die <<END
Dojo distribution version number required.
END
}

if (! -f 'Makefile.PL') {
    die <<END
This program must be run within the HTML-Dojo distribution folder.
END
}

if (! -d 'dojo') {
    die <<END;
Dojo source directory missing.
The HTML-Dojo directory should contain a directory named 'dojo', 
which should contain all the Dojo editions, already unzipped.
END
}

our $dojo_version = shift @ARGV;

### search for distributions
###
opendir my $source_dir, 'dojo'
    or die "failed to open directory 'dojo': $!";

my %folders;
for (readdir $source_dir) {
    $folders{$_} = 1 if /^dojo-\Q$dojo_version\E-\w+$/;
}
closedir $source_dir;

{
    for my $edition (sort keys %folders) {
        print "Found new edition: '$edition'. Update HTML::Dojo::editions()\n"
            if ! grep { $edition =~ /-$_$/ } HTML::Dojo->editions();
    }
}
{
    for my $edition (HTML::Dojo->editions()) {
        print "No folder found for edition: $edition\n"
            if ! grep { $_ eq "dojo-$dojo_version-$edition" } keys %folders;
    }
}

### build the main tree from the 'core' edition
###
my ($core_dir) = grep { /-core$/ } keys %folders;

open my $src_pm_fh, '>', "lib/HTML/Dojo/src.pm"
    or die "failed to open: $!";
binmode $src_pm_fh;

print $src_pm_fh <<PM;
package HTML::Dojo::src;
1;
__DATA__
PM

find( \&parse_src_dir, "dojo/$core_dir/src" );

close $src_pm_fh;

### build the different editions files
###
open my $editions_pm_fh, '>', "lib/HTML/Dojo/editions.pm"
    or die "failed to open: $!";
binmode $editions_pm_fh;

print $editions_pm_fh <<PM;
package HTML::Dojo::editions;
1;
__DATA__
PM

for my $edition_dir (sort keys %folders) {
    $edition_dir =~ /(\w+)$/ or die "bad folder name";
    my $edition = $1;
    for my $file (HTML::Dojo->_editions_files()) {
        my $path = "dojo/$edition_dir/$file";
        
        if (! -f $path) {
            print "SKIPPING FILE NOT FOUND: $path\n";
            next;
        }
        
        printf $editions_pm_fh "__CPAN_EDITION__ %s %s\n", $edition, $file;
        
        open my $js_fh, '<', $path
            or die "failed to open '$path': $!";
        binmode $js_fh;
        
        my $slurp = do { local $/; <$js_fh> };
        
        print $editions_pm_fh "$slurp\n";
    }
}
close $editions_pm_fh;

### build the common files
###
open my $common_pm_fh, '>', "lib/HTML/Dojo/common.pm"
    or die "failed to open: $!";
binmode $common_pm_fh;

print $common_pm_fh <<PM;
package HTML::Dojo::common;
1;
__DATA__
PM

for my $file (HTML::Dojo->_common_files()) {
    my $path = "dojo/$core_dir/$file";
    
    if (! -f $path) {
        print "SKIPPING FILE NOT FOUND: $path\n";
        next;
    }
    
    printf $common_pm_fh "__CPAN_COMMON__ %s\n", $file;
    
    open my $js_fh, '<', $path
        or die "failed to open '$path': $!";
    binmode $js_fh;
    
    my $slurp = do { local $/; <$js_fh> };
    
    print $common_pm_fh "$slurp\n";
}
close $common_pm_fh;

### copy the license file
###
copy "dojo/$core_dir/LICENSE", "DOJO_LICENSE"
    or die "failed to copy license file: $!";

###

sub parse_src_dir {
    my $file = $File::Find::name;
    $file =~ s|dojo\/$core_dir\/||;
    
    printf $src_pm_fh "__CPAN_%s__ %s\n", (-d $_ ? "DIR" : "FILE"), $file;
    
    return if -d $_;
    
    open my $fh, '<', $_
        or die "failed to open file '$File::Find::name': $!";
    binmode $fh;
    
    my $slurp = do { local $/; <$fh> };
    
    print $src_pm_fh "$slurp\n";
    close $fh;
}
