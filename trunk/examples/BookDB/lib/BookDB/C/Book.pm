package BookDB::C::Book;

use strict;
use base 'Catalyst::Base';
use Net::Amazon;

=head1 NAME

BookDB::C::Book - Scaffolding Controller Component

=head1 SYNOPSIS

See L<BookDB>

=head1 DESCRIPTION

Scaffolding Controller Component.

=head1 METHODS

=over 4

=item add

Sets a template.

=cut

sub add : Local {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'Book/add.tt';
}

=item default

Forwards to list.

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->forward('list');
}

=item destroy

Destroys a row and forwards to list.

=cut

sub destroy : Local {
    my ( $self, $c, $id ) = @_;
    BookDB::M::BookDB::Book->retrieve($id)->delete;
    $c->forward('list');
}

=item do_add

Adds a new row to the table and forwards to list.

=cut

sub do_add : Local {
    my ( $self, $c ) = @_;
    $c->form( required => [qw /title author/],
              optional => [ BookDB::M::BookDB::Book->columns ] );
    BookDB::M::BookDB::Book->create_from_form( $c->form );
    $c->forward('list');
}

=item do_edit

Edits a row and forwards to edit.

=cut

sub do_edit : Local {
    my ( $self, $c, $id ) = @_;
    $c->form( optional => [ BookDB::M::BookDB::Book->columns ] );
    BookDB::M::BookDB::Book->retrieve($id)->update_from_form( $c->form );
    $c->forward('edit');
}

=item edit

Sets a template.

=cut

sub edit : Local {
    my ( $self, $c, $id ) = @_;
    $c->stash->{item} = BookDB::M::BookDB::Book->retrieve($id);
    $c->stash->{template} = 'Book/edit.tt';
}

=item list

Sets a template.

=cut

sub list : Local {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'Book/list.tt';
}

=item view

Fetches a row and sets a template.

=cut

sub view : Local {
    my ( $self, $c, $id ) = @_;
    $c->stash->{item} = BookDB::M::BookDB::Book->retrieve($id);
    $c->stash->{template} = 'Book/view.tt';
}

=item do_checkout

=cut

sub do_checkout : Local {
    my ( $self, $c, $id ) = @_;
    $c->form( required => [ qw/borrower/ ], 
	      defaults => { borrowed => "".localtime } );
    BookDB::M::BookDB::Book->retrieve($id)->update_from_form( $c->form );
    $c->forward('view');
}

=item do_return

=cut

sub do_return : Local {
    my ( $self, $c, $id ) = @_;
    $c->stash->{item} = BookDB::M::BookDB::Book->retrieve($id);
    $c->stash->{item}->borrowed(undef);
    $c->stash->{item}->borrower(undef);
    $c->stash->{item}->update;
    $c->stash->{template} = 'Book/view.tt';
}

=item
=cut

sub do_add_from_isbn : Local {
   my ($self, $c) = @_;
   my $ua = Net::Amazon->new(token => $c->config->{amazon_token} ||
				      'D13HRR2OQKD1Y5');
   my $response = $ua->search( asin => $c->req->param('isbn') );
   my ($prop) = $response->properties;
   if ($response->is_success()) {
	$c->req->param('title', $prop->title);
	$c->req->param('publisher', $prop->publisher);
	$c->req->param('year', $prop->year);
	$c->req->param('author',join( "/", $prop->authors ) );
	# Jump to the standard routine
	$c->forward('do_add');
   } else {
	$c->stash->{message} = "Object not found: ".$response->message();
	$c->stash->{template} = 'Book/add.tt';
   }
}

=back

=head1 AUTHOR

Marcus Ramberg

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
