package Catalyst::Build;

use strict;
use Module::Build;
use Path::Class;
use File::Find 'find';

our @ISA;
eval "require Module::Build";
die "Please install Module::Build\n" if $@;
push @ISA, 'Module::Build';

our @ignore =
  qw/Build Build.PL Changes MANIFEST META.yml Makefile.PL Makefile README
  _build blib lib script t/;

our $FAKE;
our $ignore = '^(' . join( '|', @ignore ) . ')$';

=head1 NAME

Catalyst::Build - Module::Build extension for Catalyst

=head1 SYNOPSIS

See L<Catalyst>

=head1 DESCRIPTION

L<Module::Build> extension for Catalyst.

=head1 DEPRECATION NOTICE

This module is deprecated in favor of L<Module::Install::Catalyst>. It's
only left here for compability with older applications.

=head1 METHODS

=over 4

=item new

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    my $app_name = $self->{properties}{module_name};
    warn <<"EOF";

 Note:

    The use of Build.PL for building and distributing Catalyst
    applications is deprecated in Catalyst 5.58.

    We recommend using the new Module::Install-based Makefile
    system.  You can generate a new Makefile.PL for your application
    by running:

        catalyst.pl -force -makefile $app_name

EOF

    return $self;
}

=item ACTION_install

=cut

sub ACTION_install {
    my $self = shift;
    $self->SUPER::ACTION_install;
    $self->ACTION_install_extras;
}

=item ACTION_fakeinstall

=cut

sub ACTION_fakeinstall {
    my $self = shift;
    $self->SUPER::ACTION_fakeinstall;
    local $FAKE = 1;
    $self->ACTION_install_extras;
}

=item ACTION_install_extras

=cut

sub ACTION_install_extras {
    my $self    = shift;
    my $prefix  = $self->{properties}{destdir} || undef;
    my $sitelib = $self->install_destination('lib');
    my @path    = defined $prefix ? ( $prefix, $sitelib ) : ($sitelib);
    my $path    = dir( @path, split( '::', $self->{properties}{module_name} ) );
    my @files   = $self->_find_extras;
    print "Installing extras to $path\n";
    for (@files) {
        $FAKE
          ? print "$_ -> $path (FAKE)\n"
          : $self->copy_if_modified( $_, $path );
    }
}

sub _find_extras {
    my $self = shift;
    my @all  = glob '*';
    my @files;
    for my $file (@all) {
        next if $file =~ /$ignore/;
        if ( -d $file ) {
            find(
                sub {
                    return if -d;
                    push @files, $File::Find::name;
                },
                $file
            );
        }
        else { push @files, $file }
    }
    return @files;
}

=back

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
