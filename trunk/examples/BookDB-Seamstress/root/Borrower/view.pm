package root::Borrower::view;

use strict;
use warnings;

use BookDB::M::BookDB::Borrower;
use base qw( HTML::Seamstress ) ;
#use base qw( BookDB::V::Seamstress ) ;

use Carp qw(carp cluck croak confess);
use Class::ISA;
use Data::Dumper;

sub new {
  my ($class, $c) = @_;

  #warn '__NEW__ called';

  my $html_file = sprintf "%s", $c->path_to('root/Borrower/view.html');

  my $tree = __PACKAGE__->new_from_file($html_file);

  $tree;
}

sub process {
  my ($tree, $c, $stash) = @_;


  my @dual_data = map {

    [$_->name, $stash->{item}->$_]

  } ($stash->{item}->columns('view')) ;

  $tree->iter2(
    debug => 1,
    wrapper_ld => [ class => 'columns_view' ],
    wrapper_data => \@dual_data,
    item_ld => sub {  
      [	shift()->look_down(class => qr/column_(name|value)/) ] ;
    }
   );

  $tree->table2(
    debug => 1,
    table_data => [ $stash->{item}->books ],
    tr_ld => [ class => 'data_row' ],
    td_proc => sub {
      my ($tr, $data) = @_;
      $tr->look_down(class => $_)->replace_content($data->$_)
	  for qw(title borrowed);
      $tr->look_down(class => "book_view")->attr(
	href => sprintf "/book/view/%d", $data->id
       );
      $tr->look_down(class => "book_return")->attr(
	href => sprintf "/book/do_return/%d", $data->id
       );
    }
   );

  $tree;
}

1;
