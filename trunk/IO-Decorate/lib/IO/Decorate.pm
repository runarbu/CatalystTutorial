package IO::Decorate;

use strict;
use warnings;

use IO::Handle;

our $VERSION = 0.01;
our $AUTOLOAD;

sub new {
    my $class     = ref $_[0] ? ref shift : shift;
    my $decorated = shift;
    my $decorator = bless( \$decorated, $class );
    return $decorator;
}

sub can       { shift->decorated->can(@_)        }
sub isa       { shift->decorated->isa(@_)        }

sub decorator { $_[0]                            }
sub decorated {
    my $self = shift;

    if ( @_ == 1 ) {
        ${ $self } = $_[0];
    }

    return ${ $self };
}

# IO::Handle
sub autoflush { shift->decorated->autoflush (@_) }
sub close     { shift->decorated->close     (@_) }
sub eof       { shift->decorated->eof       (@_) }
sub fileno    { shift->decorated->fileno    (@_) }
sub flush     { shift->decorated->flush     (@_) }
sub getc      { shift->decorated->getc      (@_) }
sub getline   { shift->decorated->getline   (@_) }
sub getlines  { shift->decorated->getlines  (@_) }
sub opened    { shift->decorated->opened    (@_) }
sub print     { shift->decorated->print     (@_) }
sub printf    { shift->decorated->printf    (@_) }
sub read      { shift->decorated->read      (@_) }
sub stat      { shift->decorated->stat      (@_) }
sub sysread   { shift->decorated->sysread   (@_) }
sub syswrite  { shift->decorated->syswrite  (@_) }
sub truncate  { shift->decorated->truncate  (@_) }
sub ungetc    { shift->decorated->ungetc    (@_) }
sub write     { shift->decorated->write     (@_) }

# IO::File
sub open      { shift->decorated->open      (@_) }

# IO::Seekable
sub seek      { shift->decorated->seek      (@_) }
sub sysseek   { shift->decorated->sysseek   (@_) }
sub tell      { shift->decorated->tell      (@_) }

# Why is this method only available in IO::File, should it not be in IO::Handle?
# Make it available here since it's a common method.
sub binmode   {
    my $self = shift;

    unless ( $self->decorated->can('binmode') ) {
        return binmode $self->decorated unless @_;
        return binmode $self->decorated, @_;
    }

    $self->decorated->binmode(@_);
}

sub AUTOLOAD {
    my $self   = shift;
    my $method = substr( $AUTOLOAD, rindex( $AUTOLOAD, ':' ) + 1 );
    return $self->decorated->$method(@_);
}

sub DESTROY { }

1;

__END__

=head1 NAME

IO::Decorate - Decorate IO handles

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item new

=item decorator

=item decorated

=back

=head1 SEE ALSO

L<IO::Decorate::Tie>.

=head1 AUTHOR

Christian Hansen C<ch@ngmedia.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify 
it under the same terms as Perl itself.

=cut
