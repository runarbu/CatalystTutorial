package Text::Folksonomies;

use strict;

our $VERSION = '0.02';

=head1 NAME

Text::Folksonomies - Simple folksonomy parser

=head1 SYNOPSIS

    use Text::Folksonomies;

    my $text = q/test product 'foo bar' red 'lala yada' "hello you" green/;

    my $f = Text::Folksonomies->new;
    my @folksonomies = @{ $f->parse($text) };

=head1 DESCRIPTION

Simple folksonomy parser.

=head2 METHODS

=cut 

sub new { bless {}, shift }

=head3 parse

Extract folksonomies from text.
Returns an arrayref with folksonomies.

=cut

sub parse {
    my ( $self, $text ) = @_;
    my @folksonomies;
    for ( map { /['"]/ ? ( s/['"]//g && $_ ) : split }
        split /(['"][^'"]*['"])/, $text )
    {
        s/\s+/ /g;
        s/[^\w\s]//g;
        push @folksonomies, $_;
    }
    return \@folksonomies;
}

=head1 AUTHOR

Sebastian Riedel, C<sri@cpan.org>
Juergen Peters, C<taulmaril@cpan.org>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
