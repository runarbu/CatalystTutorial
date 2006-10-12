package BookDB::C::Borrower;

use strict;
use base 'Catalyst::Base';

=head1 NAME

BookDB::C::Borrower - Scaffolding Controller Component

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
#    $c->stash->{template} = 'Borrower/add.tt';
    $c->stash->{LOOM} = 'root::Borrower::add';
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
    BookDB::M::BookDB::Borrower->retrieve($id)->delete;
    $c->forward('list');
}

=item do_add

Adds a new row to the table and forwards to list.

=cut

sub do_add : Local {
    my ( $self, $c ) = @_;
    $c->form( 
	required => [ qw/name email/ ],
	optional => [ BookDB::M::BookDB::Borrower->columns ],
	constraints => {email => 'email'});
    if ($c->form->has_missing) {
        $c->stash->{message}='You have to fill in all fields.'.
        'the following are missing: <b>'.
        join(', ',$c->form->missing()).'</b>';
    } elsif ($c->form->has_invalid) {
        $c->stash->{message}='Some fields are invalid. Please '.
                             'correct them and try again:';
    } else {
    	BookDB::M::BookDB::Borrower->create_from_form( $c->form );
    	return $c->forward('list');
    }
    $c->forward('add');
}

=item do_edit

Edits a row and forwards to edit.

=cut

sub do_edit : Local {
    my ( $self, $c, $id ) = @_;
    $c->form( 
	required=> [ qw/name email/ ],
	optional => [ BookDB::M::BookDB::Borrower->columns ] );
    if ($c->form->has_missing) {
        $c->stash->{message}='You have to fill in all fields.'.
        'the following are missing: <b>'.
        join(', ',$c->form->missing()).'</b>';
    } elsif ($c->form->has_invalid) {
        $c->stash->{message}='Some fields are invalid. Please '.
                             'correct them and try again:';
    } else {
	BookDB::M::BookDB::Borrower->retrieve($id)->update_from_form( $c->form );
    }
    $c->forward('edit');
}

=item edit

Sets a template.

=cut

sub edit : Local {
    my ( $self, $c, $id ) = @_;
    $c->stash->{item} = BookDB::M::BookDB::Borrower->retrieve($id);
    $c->stash->{template} = 'Borrower/edit.tt';
}

=item list

Sets a template.

=cut

sub list : Local {
    my ( $self, $c ) = @_;
#    $c->stash->{template} = 'Borrower/list.tt';
    $c->stash->{LOOM} = 'root::Borrower::list';
}

=item view

Fetches a row and sets a template.

=cut

sub view : Local {
    my ( $self, $c, $id ) = @_;
    $c->stash->{item} = BookDB::M::BookDB::Borrower->retrieve($id);
#    $c->stash->{template} = 'Borrower/view.tt';
    $c->stash->{LOOM} = 'root::Borrower::view';
}

=back

=head1 AUTHOR

Marcus Ramberg

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
