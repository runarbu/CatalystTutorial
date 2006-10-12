package Catalyst::Plugin::Forward;

use strict;

our $VERSION='0.1';

use Carp ();

sub forward_class {
    my ( $c, $class, $method, @arguments ) = @_;

    unless (  @_ >= 3 ) {
        Carp::croak('usage: $c->forward_class( $class, $method [, @arguments ] )');
    }

    local $c->request->{arguments} = \@arguments;

    return $c->forward( $class, $method );
}

sub forward_path {
    my ( $c, $path, @arguments ) = @_;

    unless ( @_ >= 2 ) {
        Carp::croak('usage: $c->forward_path( $path [, @arguments ] )');
    }

    local $c->request->{arguments} = \@arguments;

    return $c->forward($path);
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Forward - Forward with arguments

=head1 SYNOPSIS

    use Catalyst qw[Forward];

    sub default : Private {
        my ( $self, $c ) = @_;
        $c->forward_class( 'MyApp::View::TT', 'process', @arguments );
        $c->forward_path( '/my/path', @arguments );
    }


=head1 DESCRIPTION

Extends base class with a forward_class and forward_path methods that 
takes arguments.

=head1 METHODS

=over 4

=item forward_class( $class, $method [, @arguments ] )

Like << $c->forward >> but passes arguments to the forwared method.

=item forward_path( $path [, @arguments ] )

Like << $c->forward >> but passes arguments to the forwared method.

=back

=head1 SEE ALSO

L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as perl itself.

=cut
