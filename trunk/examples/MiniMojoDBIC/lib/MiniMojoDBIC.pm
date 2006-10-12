package MiniMojoDBIC;

use strict;
use warnings;

#
# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
# Static::Simple: will serve static files from the application's root 
# directory
#
use Catalyst qw/-Debug ConfigLoader Static::Simple Prototype Textile/;

our $VERSION = '0.01';

#
# Start the application
#
__PACKAGE__->setup;

#
# IMPORTANT: Please look into MiniMojoDBIC::Controller::Root for more
#

=head1 NAME

MiniMojo - A very nice application

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice application.

=head1 AUTHOR

Clever guy

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
