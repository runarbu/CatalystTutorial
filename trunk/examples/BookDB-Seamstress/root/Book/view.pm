package root::Book::view;

use strict;
use warnings;

use BookDB::M::BookDB::Book;
use base qw( HTML::Seamstress ) ;
#use base qw( BookDB::V::Seamstress ) ;

use Carp qw(carp cluck croak confess);
use Class::ISA;
use Data::Dumper;

sub new {
  my ($class, $c) = @_;

  #warn '__NEW__ called';

  my $html_file = sprintf "%s", $c->path_to('root/Book/view.html');

  my $tree = __PACKAGE__->new_from_file($html_file);

  $tree;
}

sub process {
  my ($tree, $c, $stash) = @_;


  my $book_props = $tree->look_down(id => 'book_props');

  for my $column (BookDB::M::BookDB::Book->columns('view')) {
    my $bp = $book_props->clone;
    my $column_nm = $column->name;

    warn $column_nm;
    $bp->look_down(class => "title")->replace_content($column_nm);
    my $val = $stash->{item}->$column_nm;
    warn "val: $val";
    $bp->look_down(id => "val")->replace_content("$val");
    $book_props->parent->push_content($bp);
  }

  $book_props->detach;

  $tree->highlander2(book_status => [
    checked_out     => [
      sub { $stash->{item}->borrower },
      sub { 
	my $branch = shift; 
	my %a;
	$a{borrower}  = {
	  href => '/borrower/view/' . $stash->{item}->borrower->id,
	  content => $stash->{item}->borrower->name
	 };
	$a{do_return} = {
	  href    => "/book/do_return/" . $stash->{item}->id,
	  content =>'Return book'
	 };

	for (keys %a) {
	  my $a_elem = $branch->look_down(id => $_);
	  $a_elem->replace_content("$a{$_}{content}");
	  $a_elem->attr(href => "$a{$_}{href}");
	}

	my $borrowed = $branch->look_down(id => 'item_borrowed');
	$borrowed->replace_content($stash->{item}->borrowed);

      }
     ],
    not_checked_out => [
      sub { 1 },
      sub { 
	my $branch = shift;
	my $html = $stash->{item}->to_field('borrower');
	use Data::Dumper;
	warn "ITEM_TO_FIELD: ", Dumper $html;
	$branch->look_down(id => 'select')->replace_content($html);
      }
     ]
   ]);


  $tree;
}

1;
