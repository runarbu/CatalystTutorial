#!/usr/bin/perl

use strict;
use IO::Handle;
use File::Spec;
use YAML;

my $REPO = 'http://dev.catalyst.perl.org/repos/Catalyst';
my $SVN = -d '.svn' ? 'svn' : 'svk';
my ($name,$version);

print "\n";
unless (-e 'Build.PL' or -e 'Makefile.PL') {
    print "Error: must be run from a directory with Build.PL or Makefile.PL present\n\n";
    exit 1;
}
run();
print "\n";

sub run {
    check_commit();
    -e 'Build.PL' ? dist_build() : dist_makefile();

    if (-e 'META.yml') {
        my $meta = YAML::LoadFile('META.yml');
        $name = $meta->{name};
        $version = $meta->{version};

        cpan_upload();
        make_tag();        
    }
}

sub check_commit {
    print "Checking for uncommitted files... ";
    STDOUT->flush;
    
    my @files = grep { ! /^\?/ } split( "\n", `$SVN st` );
    if (@files) {
        print "\n\n", join("\n", @files), "\n\nPlease commit them before releasing.\n\n";
        exit 1;
    } else {
        print "none found.\n";
    }
}

sub dist_build {
    do_cmd("perl Build.PL");
    do_cmd("rm -f MANIFEST");
    make_modinstall_readme() if -d 'inc' and -e 'Makefile.PL';
    do_cmd("perl Build manifest");
    {
        local $ENV{TEST_POD} = 1;
        do_cmd("perl Build disttest");
    }
    do_cmd("perl Build dist");
}

sub dist_makefile {
    do_cmd("perl Makefile.PL --defaultdeps");
    do_cmd("rm -f MANIFEST");
    make_modinstall_readme();
    do_cmd("make manifest");
    do_cmd("make disttest");
    do_cmd("make dist");
}

sub make_modinstall_readme {
    my $name = `grep "^name('" Makefile.PL`;
    $name =~ /^name\('(.+)'\)/;
    my @path = split /-/, $1;
    $path[-1] .= '.pm';
    my $path = File::Spec->catfile('lib', @path);
    warn ("\nWarning: could not create README"), return unless -r $path;

    require Pod::Text;
    my $parser = Pod::Text->new;
    $parser->parse_from_file($path, 'README');
}

sub cpan_upload {
    print ("No ~/.pause file found, skipping cpan-upload\n"), return unless -e "$ENV{HOME}/.pause";
    
    my $distfile = "$name-$version.tar.gz";
    print "\nDo you wish to upload $distfile to CPAN with cpan-upload? (y/n) ";
    my $answer = <STDIN>;
    do_cmd("cpan-upload $distfile",1) if $answer =~ /^y/;
}

sub make_tag {
    my $trunk = "$REPO/trunk/$name";
    my $tag = "$REPO/tags/$name";
    
    print qq(\nDo you wish to create a tag with "svn copy $trunk $tag/$version"? (y/n) );
    my $answer = <STDIN>;
    if ($answer =~ /^y/) {
        print "\nChecking if $tag exists... ";
        STDOUT->flush;
        if (system "svn list $tag >/dev/null 2>&1") {
            print "not found, creating.\n";
            do_cmd("svn mkdir $tag -m '- created tag directory for $name'");
        } else {
            print "found.\n";
        }
        
        do_cmd("svn copy $trunk $tag/$version -m '- tagged $name-$version'", 1);        
    }
}

sub do_cmd {
    my ($cmd,$continue) = @_;
    print "\n>>> $cmd\n";
    system($cmd) and !$continue and exit 1;
}
