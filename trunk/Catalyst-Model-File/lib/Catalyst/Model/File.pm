package Catalyst::Model::File;

use strict;
use warnings;

use base qw/Catalyst::Model/;
use NEXT;
use Carp;

use IO::Dir;
use Path::Class ();
use IO::File;

our $VERSION = 0.02;

=head1 NAME

Catalyst::Model::File - File based storage model for Catalyst.

=head1 SYNOPSIS

# use the helper to create a model
    myapp_create.pl model File File

# configure in lib/MyApp.pm

    MyApp->config(
        name          => 'MyApp',
        root          => MyApp->path_to('root'),
        'Model::File' => {
            directory => MyApp->path_to('file_store')

Simple file based storage model for Catalyst.

  @file_names = $c->model('File')->list;

=head1 METHODS

=head2 new

=cut

sub new {
    my $self = shift->NEXT::new(@_);

    croak "->config->{root_dir} must be defined for this model"
        unless $self->{root_dir};

    unless (ref $self->{root_dir} ) {
        # If a string is provided turn into a Path::Class
        $self->{root_dir} = Path::Class::dir($self->{root_dir})
    }

    $self->{dir_create_mask} ||= 0775;
    $self->{root_dir}->mkpath(0, $self->{dir_mask});
    $self->{directory} = Path::Class::dir('/');
    $self->{_dir} = $self->{root_dir};

    return $self;
}

=head2 list

Returns a list of files (and/or directories) found under the current working 
dir. Default will return files (including those found under sub-directories)
but not directories.

To change this behaviour specify a C<mode> param of C<files> (default), 
C<dirs> or C<both>:

 $mdl->list(mode => 'both')

To only get files/dirs directly under the current dir specify a C<recurse> option of 0.

Please note: the exact order in which files and directories are listed will
change from OS to OS.

=cut

sub list {
    $DB::single = 1;
    my ($self, %opt) = @_;
    my @files;
    $opt{mode} ||= 'files';
    $opt{recurse} = 1 unless exists $opt{recurse};

    $opt{dir}  = 1 if $opt{mode} =~ /^both|dirs$/;
    $opt{file} = 1 if $opt{mode} =~ /^both|files$/;

    if ($opt{recurse}) {
        $self->{_dir}->recurse(callback => sub {
            my ($entry) = @_;
            push @files, $entry->relative($self->{_dir})
                if !$entry->is_dir && $opt{file} 
                || $entry->is_dir && $opt{dir};
        });
        return @files;
    }

    @files = map {$_->relative($self->{_dir}) } $self->{_dir}->children;

    return @files if $opt{dir} && $opt{file};

    my $meth = $opt{dir} ? 'is_dir' : 'is_file';

    return map { $_->relative($self->{_dir}) } 
        grep { $_->is_dir && $opt{dir} || !$_->is_dir && $opt{file}
        } @files;
}

=head2 change_dir

=head2 cd

Set current working directory (relative to current) and return $self.

=cut

sub cd { shift->change_dir(@_) }


sub change_dir {
    $DB::single = 1;
    my $self = shift;

    my $dir = shift;

    return $self unless defined $dir;

    $dir = Path::Class::dir($dir, @_) unless ref $dir;

    my @dir_list = ();
    $self->{directory} = Path::Class::dir('');

    if ($dir->is_absolute) {
        $self->{_dir} = $self->{root_dir};
        @dir_list = $dir->dir_list(1);
    } else {
        $dir = $self->{_dir}->subdir($dir);
        $self->{_dir} = $self->{root_dir};
        return $self unless ($self->{root_dir}->subsumes($dir) );
        
        @dir_list = $dir->relative($self->{root_dir})->dir_list;
    }
    

#    $self->{directory} = $self->{directory}->subdir(@dir_list);
    foreach my $subdir (@dir_list) {
        $self->{_dir} = $self->{_dir}->subdir($subdir) unless $subdir eq '..';
        $self->{_dir} = $self->{_dir}->parent if $subdir eq '..';
    }

    $self->{directory} = $self->{_dir}->relative($self->{root_dir})->absolute('/');

    return $self;
}

=head2 directory

=head2 pwd

Get the current working directory, from which all relative paths are based.

=cut

sub pwd { shift->directory(@_) }

sub directory {
    return shift->{directory};
}

=head2 parent

Move up to the parent of the working directory. Returns $self.

=cut

sub parent {
    my ($self) = @_;

    $self->{_dir} = $self->{_dir}->parent;

    unless ($self->{root_dir}->subsumes($self->{_dir})) {
        $self->{_dir} = $self->{root_dir};
        return $self;
    }

    $self->{directory} = $self->{_dir}->relative($self->{root_dir})->absolute('/');

    return $self;
}

=head2 $self->file($file)

Returns an L<Class::Path::File> object of $file (which can be a string or a Class::Path::File object,) or undef if the file is an invalid path - i.e. outside the directory structure specified in the config.

=cut

sub file {
    my ($self, $file) = @_;

    return unless $file;

    $file = (ref $file ? $file : Path::Class::file($file) )->absolute($self->{_dir});

    return undef unless $self->{root_dir}->subsumes($file);

    # Make sure the dir tree exists
    $file->dir->mkpath(0, $self->{dir_create_mask});
    return $file;
    
}

=head2 $self->slurp($file)

Shortcut to $self->file($file)->slurp.

In a scalar context, returns the contents of $file in a string.  In a list context,
returns the lines of $file (according to how $/ is set) as a list.  If the file can't be
read, this method will throw an exception.

If you want "chomp()" run on each line of the file, pass a true value for the "chomp" or
"chomped" parameters:

 my @lines = $self->slurp($file, chomp => 1);


=cut

sub slurp {
    my $file = shift->file(shift) or return wantarray ? () : undef;

    return $file->stat ? $file->slurp(@_) : wantarray ? () : undef;
}

=head2 $self->splat($file, PRINT_ARGS)

Does a print to C<$file> with the specified C<PRINT_ARGS>. Does the same as C<$self->file->openw->print(@_)>

=cut

sub splat {
    my $file = shift->file(shift) or return;

    $file->openw->print(@_);
}


=head1 AUTHOR

Ash Berlin, C<ash@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;