package Catalyst::View::TT::Restricted;

use strict;
use base 'Catalyst::View::TT';
use NEXT;

our $VERSION = '0.01';

__PACKAGE__->config->{ABSOLUTE} = 0;
__PACKAGE__->config->{LOAD_PERL} = 0;
__PACKAGE__->config->{ANYCASE} = 1;
__PACKAGE__->config->{AUTO_RESET} = 1;
__PACKAGE__->config->{INCLUDE_PATH} = undef;
__PACKAGE__->config->{PLUGIN_BASE} = undef;


sub process {
    my ($self,$c) = @_;
    # undef is a value, so overrides ::TT
    undef $c->stash->{c};
    my $process=$self->NEXT::process($c);
    delete $c->stash->{c}; # clean up stash.
    return $process;
}

=head1 NAME

Catalyst::View::TT::Restricted - Secure TT template processing

=head1 SYNOPSIS

=head1 DESCRIPTION

A Restricted version of the Catalyst TT view.

=head2 OVERRIDDEN METHODS

=over 4

=item process

Overrides C<process> to make sure C<$c> is not available in the stash .

=back

=cut

=head1 SEE ALSO

L<Catalyst>. L<Catalyst::View::TT>

=head1 AUTHOR

Marcus Ramberg, C<mramberg@cpan.org>

=head1 THANK YOU

SRI, for writing the awesome Catalyst framework

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
