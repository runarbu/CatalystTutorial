package Catalyst::Plugin::Component::Loader;

use strict;

our $VERSION = '0.1';

sub setup_components {
    my $self = shift;
    $self->retrieve_components;
    $self->instantiate_components;
}

sub retrieve_components {
    my $self = shift;

    eval {
        Module::Pluggable::Fast->import(
            name    => '_components',
            search  => [
                "$self\::Controller", "$self\::C",
                "$self\::Model",      "$self\::M",
                "$self\::View",       "$self\::V"
            ],
            require => 1
        );
    };

    if ( my $error = $@ ) {
        chomp $error;
        die qq/Couldn't load components "$error"/;
    }

    for my $component ( $self->_components ) {
        $self->components->{$component} = $component;
    }
}

sub instantiate_components {
    my $self = shift;

    for my $component ( keys %{ $self->components } ) {

        next unless $component->isa('Catalyst::Base');

        eval {
            $self->components->{$component} = $component->new($self);
        };

        if ( my $error = $@ ) {
            chomp $error;
            die qq/Couldn't instantiate component "$component", "$error"/;
        }
    }
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Component::Loader - Catalyst Component Loader

=head1 SYNOPSIS

    use Catalyst qw[Component::Loader];


=head1 DESCRIPTION

A more sane loader

=head1 OVERLOADED METHODS

=over 4

=item setup_components

Overloads setup_components from C<Catalyst::Engine>.

=back

=head1 METHODS

=over 4

=item retrieve_components

Uses C<Module::Pluggable::Fast> to retrieve components.

=item instantiate_components

Instantiates all components that inherits from C<Catalyst::Base>.

=back

=head1 SEE ALSO

L<Catalyst>, L<Catalyst::Engine>

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut
