package Catalyst::Helper::View::TT;

use strict;

=head1 NAME

Catalyst::Helper::View::TT::Restricted - Helper for Restricted TT Views

=head1 SYNOPSIS

    script/create.pl view TT::Restricted TT

=head1 DESCRIPTION

Helper for Restricted TT Views.

=head2 METHODS

=head3 mk_compclass

=cut

sub mk_compclass {
    my ( $self, $helper ) = @_;
    my $file = $helper->{file};
    $helper->render_file( 'compclass', $file );
}

=head1 SEE ALSO

L<Catalyst::View::TT>, L<Catalyst::Helper>, L<Catalyst>

=head1 AUTHOR

Marcus Ramberg, C<mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it
under the same terms as perl itself.

=cut

1;

__DATA__

__compclass__
package [% class %];

use strict;
use base 'Catalyst::View::TT::Restricted';

=head1 NAME

[% class %] - Restricted TT View Component

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice component.

=head1 AUTHOR

[% author %]

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it 
under the same terms as perl itself.

=cut

1;
