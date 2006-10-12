package Catalyst::Helper::View::XSLT;

use strict;

=head1 NAME

Catalyst::Helper::View::XSLT - Helper for XSLT Views

=head1 SYNOPSIS

    script/create.pl view XSLT XSLT

=head1 DESCRIPTION

Helper for XSLT Views.

=head2 METHODS

=head3 mk_compclass

=cut

sub mk_compclass {
    my ( $self, $helper ) = @_;
    my $file = $helper->{file};
    $helper->render_file( 'compclass', $file );
}

=head1 SEE ALSO

L<Catalyst::Manual>, L<Catalyst::Test>, L<Catalyst::Request>,
L<Catalyst::Response>, L<Catalyst::Helper>

=head1 AUTHOR

Martin Grigorov, C<mcgregory@e-card.bg>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;

__DATA__

__compclass__
package [% class %];

use strict;
use base 'Catalyst::View::XSLT';

# __PACKAGE__->config(
#	INCLUDE_PATH => [
#		MyApp->path_to( 'root', 'xslt' ),
#		MyApp->path_to( 'templates', 'xsl' ),
#	],
#	TEMPLATE_EXTENSION => '.xsl', # default extension when getting template name from the current action
#	DUMP_CONFIG => 1, # use for Debug. Will dump the final (merged) configuration for XSLT view
#	LibXSLT => { # XML::LibXSLT specific parameters
#		register_function => [
#			{
#				uri => 'urn:catalyst',
#				name => 'Hello',
#				subref => sub { return $_[0] },
#			}
#		],
#	},
#);
																																																		
=head1 NAME

[% class %] - XSLT View Component

=head1 SYNOPSIS

	See L<[% app %]>

=head1 DESCRIPTION

Catalyst XSLT View.

=head1 AUTHOR

[% author %]

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
