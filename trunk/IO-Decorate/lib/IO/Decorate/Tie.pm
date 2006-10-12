package IO::Decorate::Tie;

use strict;
use warnings;
use base 'IO::Decorate';

use IO::Handle qw[];
use Symbol     qw[];

sub new {
    my $class     = ref $_[0] ? ref shift : shift;
    my $decorated = shift;
    my $decorator = Symbol::gensym();

    tie( ${$decorator}, 'IO::Decorate::Tie::Handle', $decorator, $decorated );

    return bless( $decorator, $class );
}

sub decorator { $_[0]                            }
sub decorated { tied(${ +shift })->decorated(@_) }

package IO::Decorate::Tie::Handle;

use strict;
use warnings;

use Scalar::Util qw[];

sub decorator {
    my $self = shift;

    if ( @_ == 1 ) {
        Scalar::Util::weaken( $self->[0] = $_[0] );
    }

    return $self->[0];
}

sub decorated {
    my $self = shift;

    if ( @_ == 1 ) {
        $self->[1] = $_[0];
    }

    return $self->[1];
}

sub BINMODE   { shift->decorator->binmode   (@_) }
sub CLOSE     { shift->decorator->close     (@_) }
sub EOF       { shift->decorator->eof       (@_) }
sub GETC      { shift->decorator->getc      (@_) }
sub FILENO    { shift->decorator->fileno    (@_) }
sub OPEN      { shift->decorator->open      (@_) }
sub PRINT     { shift->decorator->print     (@_) }
sub PRINTF    { shift->decorator->printf    (@_) }
sub READ      { shift->decorator->read      (@_) }
sub READLINE  {
    wantarray
      ? shift->decorator->getlines (@_)
      : shift->decorator->getline  (@_);
}
sub SEEK      { shift->decorator->seek      (@_) }
sub TELL      { shift->decorator->tell      (@_) }
sub WRITE     { shift->decorator->write     (@_) }

sub TIEHANDLE {
    my ( $class, $decorator, $decorated ) = @_;
    my $self = bless( [], $class );
    $self->decorator($decorator);
    $self->decorated($decorated);
    return $self;
}

1;

__END__

=head1 NAME

IO::Decorate::Tie - Tie decorated IO handles

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item new

=item decorator

=item decorated

=back

=head1 SEE ALSO

L<IO::Decorate>.

=head1 AUTHOR

Christian Hansen C<ch@ngmedia.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify 
it under the same terms as Perl itself.

=cut

