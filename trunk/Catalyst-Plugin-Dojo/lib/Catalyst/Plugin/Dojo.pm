package Catalyst::Plugin::Dojo;
use strict;
use warnings;
use base qw/ Class::Accessor::Fast /;

our $VERSION = '0.01_1';


=head1 NAME

Catalyst::Plugin::Dojo - Catalyst plugin to work with the Dojo 
JavaScript / AJAX library.

=head1 SYNOPSIS

    # In your application class 
    use Catalyst qw/Dojo/;

=head1 DESCRIPTION

Provides methods to help use a Dojo library with your Catalyst application.

=head1 METHODS

=cut

sub prepare {
    my $class = shift;
    my $c     = $class->NEXT::prepare(@_);
    
    $c->stash->{dojo} = __PACKAGE__->new({ c => $c });
    
    return $c;
}

=head2 base_tag

Returns a HTML C<script> tag which will load the C<dojo.js> file.

Assumes the C<dojo.js> file is in C<root/static/dojo/>, which is the location 
L<Catalyst::Helper::Dojo> places the library in.

    # in a TT template
    [% dojo.base_tag %]

=cut

sub base_tag {
    my ($self) = @_;
    
    my $uri = $self->{c}->uri_for( '/static/dojo/dojo.js' );
    
    return qq{<script type="text/javascript" src="$uri"></script>};
}

=head1 SUPPORT

IRC:

    Join #catalyst on irc.perl.org.

Mailing Lists:

    http://lists.rawmode.org/mailman/listinfo/catalyst

For Dojo-specific support, see L<http://dojotoolkit.org>.

=head1 SEE ALSO

L<Catalyst::Helper::Dojo>, L<HTML::Dojo>, L<Catalyst::Helper>

L<http://dojotoolkit.org>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;
