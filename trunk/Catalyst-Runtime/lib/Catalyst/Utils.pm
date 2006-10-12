package Catalyst::Utils;

use strict;
use Catalyst::Exception;
use File::Spec;
use HTTP::Request;
use Path::Class;
use URI;
use Class::Inspector;

=head1 NAME

Catalyst::Utils - The Catalyst Utils

=head1 SYNOPSIS

See L<Catalyst>.

=head1 DESCRIPTION

=head1 METHODS

=head2 appprefix($class)

	MyApp::Foo becomes myapp_foo

=cut

sub appprefix {
    my $class = shift;
    $class =~ s/\:\:/_/g;
    $class = lc($class);
    return $class;
}

=head2 class2appclass($class);

    MyApp::C::Foo::Bar becomes MyApp
    My::App::C::Foo::Bar becomes My::App

=cut

sub class2appclass {
    my $class = shift || '';
    my $appname = '';
    if ( $class =~ /^(.*)::([MVC]|Model|View|Controller)?::.*$/ ) {
        $appname = $1;
    }
    return $appname;
}

=head2 class2classprefix($class);

    MyApp::C::Foo::Bar becomes MyApp::C
    My::App::C::Foo::Bar becomes My::App::C

=cut

sub class2classprefix {
    my $class = shift || '';
    my $prefix;
    if ( $class =~ /^(.*::[MVC]|Model|View|Controller)?::.*$/ ) {
        $prefix = $1;
    }
    return $prefix;
}

=head2 class2classsuffix($class);

    MyApp::C::Foo::Bar becomes C::Foo::Bar

=cut

sub class2classsuffix {
    my $class = shift || '';
    my $prefix = class2appclass($class) || '';
    $class =~ s/$prefix\:\://;
    return $class;
}

=head2 class2env($class);

Returns the environment name for class.

    MyApp becomes MYAPP
    My::App becomes MY_APP

=cut

sub class2env {
    my $class = shift || '';
    $class =~ s/\:\:/_/g;
    return uc($class);
}

=head2 class2prefix( $class, $case );

Returns the uri prefix for a class. If case is false the prefix is converted to lowercase.

    My::App::C::Foo::Bar becomes foo/bar

=cut

sub class2prefix {
    my $class = shift || '';
    my $case  = shift || 0;
    my $prefix;
    if ( $class =~ /^.*::([MVC]|Model|View|Controller)?::(.*)$/ ) {
        $prefix = $case ? $2 : lc $2;
        $prefix =~ s/\:\:/\//g;
    }
    return $prefix;
}

=head2 class2tempdir( $class [, $create ] );

Returns a tempdir for a class. If create is true it will try to create the path.

    My::App becomes /tmp/my/app
    My::App::C::Foo::Bar becomes /tmp/my/app/c/foo/bar

=cut

sub class2tempdir {
    my $class  = shift || '';
    my $create = shift || 0;
    my @parts = split '::', lc $class;

    my $tmpdir = dir( File::Spec->tmpdir, @parts )->cleanup;

    if ( $create && !-e $tmpdir ) {

        eval { $tmpdir->mkpath };

        if ($@) {
            Catalyst::Exception->throw(
                message => qq/Couldn't create tmpdir '$tmpdir', "$@"/ );
        }
    }

    return $tmpdir->stringify;
}

=head2 home($class)

Returns home directory for given class.

=cut

sub home {
    my $class = shift;

    # make an $INC{ $key } style string from the class name
    (my $file = "$class.pm") =~ s{::}{/}g;

    if ( my $inc_entry = $INC{$file} ) {
        {
            # look for an uninstalled Catalyst app

            # find the @INC entry in which $file was found
            (my $path = $inc_entry) =~ s/$file$//;
            my $home = dir($path)->absolute->cleanup;

            # pop off /lib and /blib if they're there
            $home = $home->parent while $home =~ /b?lib$/;

            # only return the dir if it has a Makefile.PL or Build.PL
            if (-f $home->file("Makefile.PL") or -f $home->file("Build.PL")) {

                # clean up relative path:
                # MyApp/script/.. -> MyApp

                my ($lastdir) = $home->dir_list( -1, 1 );
                if ( $lastdir eq '..' ) {
                    $home = dir($home)->parent->parent;
                }

                return $home->stringify;
            }
        }

        {
            # look for an installed Catalyst app

            # trim the .pm off the thing ( Foo/Bar.pm -> Foo/Bar/ )
            ( my $path = $inc_entry) =~ s/\.pm$//;
            my $home = dir($path)->absolute->cleanup;

            # return if if it's a valid directory
            return $home->stringify if -d $home;
        }
    }

    # we found nothing
    return 0;
}

=head2 prefix($class, $name);

Returns a prefixed action.

    MyApp::C::Foo::Bar, yada becomes foo/bar/yada

=cut

sub prefix {
    my ( $class, $name ) = @_;
    my $prefix = &class2prefix($class);
    $name = "$prefix/$name" if $prefix;
    return $name;
}

=head2 request($uri)

Returns an L<HTTP::Request> object for a uri.

=cut

sub request {
    my $request = shift;
    unless ( ref $request ) {
        if ( $request =~ m/^http/i ) {
            $request = URI->new($request)->canonical;
        }
        else {
            $request = URI->new( 'http://localhost' . $request )->canonical;
        }
    }
    unless ( ref $request eq 'HTTP::Request' ) {
        $request = HTTP::Request->new( 'GET', $request );
    }
    return $request;
}

=head2 ensure_class_loaded($class_name)

Loads the class unless it already has been loaded.

=cut

sub ensure_class_loaded {
    my $class = shift;

    return if Class::Inspector->loaded( $class ); # if a symbol entry exists we don't load again

    # this hack is so we don't overwrite $@ if the load did not generate an error
    my $error;
    {
        local $@;
        eval "require $class";
        $error = $@;
    }

    die $error if $error;
    die "require $class was successful but the package is not defined"
        unless Class::Inspector->loaded($class);

    return 1;
}

=head2 merge_hashes($hashref, $hashref)

Base code to recursively merge two hashes together with right-hand precedence.

=cut

sub merge_hashes {
    my ( $lefthash, $righthash ) = @_;

    return $lefthash unless defined $righthash;
    
    my %merged = %$lefthash;
    for my $key ( keys %$righthash ) {
        my $right_ref = ( ref $righthash->{ $key } || '' ) eq 'HASH';
        my $left_ref  = ( ( exists $lefthash->{ $key } && ref $lefthash->{ $key } ) || '' ) eq 'HASH';
        if( $right_ref and $left_ref ) {
            $merged{ $key } = merge_hashes(
                $lefthash->{ $key }, $righthash->{ $key }
            );
        }
        else {
            $merged{ $key } = $righthash->{ $key };
        }
    }
    
    return \%merged;
}


=head1 AUTHOR

Sebastian Riedel, C<sri@cpan.org>
Yuval Kogman, C<nothingmuch@woobling.org>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
