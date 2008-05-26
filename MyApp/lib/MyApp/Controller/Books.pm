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
    # Retrieve the usual Perl OO '$self' for this object. $c is the Catalyst
    # 'Context' that's used to 'glue together' the various components
    # that make up the application
    my ($self, $c) = @_;

    # Retrieve all of the book records as book model objects and store in the
    # stash where they can be accessed by the TT template
    $c->stash->{books} = [$c->model('DB::Books')->all];
    
    # Set the TT template to use.  You will almost always want to do this
    # in your action methods (action methods respond to user input in
    # your controllers).
    $c->stash->{template} = 'books/list.tt2';
}



=head2 url_create

Create a book with the supplied title and rating,
with manual authorization

=cut

sub url_create : Local {
    # In addition to self & context, get the title, rating & author_id args
    # from the URL.  Note that Catalyst automatically puts extra information
    # after the "/<controller_name>/<action_name/" into @_
    my ($self, $c, $title, $rating, $author_id) = @_;

    # Check the user's roles
    if ($c->check_user_roles('admin')) {
        # Call create() on the book model object. Pass the table 
        # columns/field values we want to set as hash values
        my $book = $c->model('DB::Books')->create({
                title   => $title,
                rating  => $rating
            });
        
        # Add a record to the join table for this book, mapping to 
        # appropriate author
        $book->add_to_book_authors({author_id => $author_id});
        # Note: Above is a shortcut for this:
        # $book->create_related('book_authors', {author_id => $author_id});
        
        # Assign the Book object to the stash for display in the view
        $c->stash->{book} = $book;
    
        # This is a hack to disable XSUB processing in Data::Dumper
        # (it's used in the view).  This is a work-around for a bug in
        # the interaction of some versions or Perl, Data::Dumper & DBIC.
        # You won't need this if you aren't using Data::Dumper (or if
        # you are running DBIC 0.06001 or greater), but adding it doesn't 
        # hurt anything either.
        $Data::Dumper::Useperl = 1;
    
        # Set the TT template to use
        $c->stash->{template} = 'books/create_done.tt2';
    } else {
        # Provide very simple feedback to the user
        $c->response->body('Unauthorized!');
    }
}



=head2 form_create

Display form to collect information for book to create

=cut

sub form_create : Local {
    my ($self, $c) = @_;

    # Set the TT template to use
    $c->stash->{template} = 'books/form_create.tt2';
}



=head2 form_create_do

Take information from form and add to database

=cut

sub form_create_do : Local {
    my ($self, $c) = @_;

    # Retrieve the values from the form
    my $title     = $c->request->params->{title}     || 'N/A';
    my $rating    = $c->request->params->{rating}    || 'N/A';
    my $author_id = $c->request->params->{author_id} || '1';

    # Create the book
    my $book = $c->model('DB::Books')->create({
            title   => $title,
            rating  => $rating,
        });
    # Handle relationship with author
    $book->add_to_book_authors({author_id => $author_id});

    # Store new model object in stash
    $c->stash->{book} = $book;

    # Avoid Data::Dumper issue mentioned earlier
    # You can probably omit this    
    $Data::Dumper::Useperl = 1;

    # Set the TT template to use
    $c->stash->{template} = 'books/create_done.tt2';
}



=head2 delete 

Delete a book
    
=cut

sub delete : Local {
    # $id = primary key of book to delete
    my ($self, $c, $id) = @_;

    # Search for the book and then delete it
    $c->model('DB::Books')->search({id => $id})->delete_all;

    # Use 'flash' to save information across requests until it's read
    $c->flash->{status_msg} = "Book deleted";
        
    # Redirect the user back to the list page
    $c->response->redirect($c->uri_for('/books/list'));
}



=head2 access_denied

Handle Catalyst::Plugin::Authorization::ACL access denied exceptions

=cut

sub access_denied : Private {
    my ($self, $c) = @_;

    # Set the error message
    $c->stash->{error_msg} = 'Unauthorized!';

    # Display the list
    $c->forward('list');
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
