package MyApp::Controller::Books;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

MyApp::Controller::Books - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched MyApp::Controller::Books in Books.');
}


=head2 list

Fetch all book objects and pass to books/list.tt2 in stash to be displayed

=cut
 
sub list : Local {
    # Retrieve the usual perl OO '$self' for this object. $c is the Catalyst
    # 'Context' that's used to 'glue together' the various components
    # that make up the application
    my ($self, $c) = @_;

    # Retrieve all of the book records as book model objects and store in the
    # stash where they can be accessed by the TT template
    $c->stash->{books} = [$c->model('MyAppDB::Book')->all];
    
    # Set the TT template to use.  You will almost always want to do this
    # in your action methods.
    $c->stash->{template} = 'books/list.tt2';
}


=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
