package root::Book::list;

use BookDB::M::BookDB::Book;
use base qw( HTML::Seamstress ) ;
#use base qw( BookDB::V::Seamstress ) ;

use Carp qw(carp cluck croak confess);
use Class::ISA;
use Data::Dumper;

sub new {
  my ($class, $c) = @_;

  #warn '__NEW__ called';

  my $html_file = sprintf "%s", $c->path_to('root/Book/list.html');

  my $tree = __PACKAGE__->new_from_file($html_file);

  $tree;
}

sub process {
  my ($tree, $c, $stash) = @_;


  my $tr_elem = $tree->look_down(id => 'title_row');

  for my $column (BookDB::M::BookDB::Book->columns('list')) {
    $tr_elem->look_down(id => "$column")->replace_content("$column");
  }




  #warn "CLASS_ISA2", join("\n\t", Class::ISA::self_and_super_path(ref $tree));
  #warn "pre-table2 INC: ", Dumper \%INC;
  #warn "CAN RES: " , HTML::Element->can('table2');

  my $counter;
  $tree->table2(
#  HTML::Element::table2(    $tree,

#    debug => 1,
    table_ld => [ id => 'books' ],
    table_data => scalar BookDB::M::BookDB::Book->retrieve_all,
    tr_ld => [ class => 'alt' ],
    tr_data => sub { 
      my ($self, $data) = @_;
      $data->next;
    },
    tr_proc => sub {
      my ($self, $tr, $tr_data, $tr_base_id, $row_count) = @_;
      #      warn "TRIN: $tr";
      $tr->attr(id => sprintf "%s_%d", 'tr_base_id', $row_count);
      $tr->attr(class => undef) if $counter++ % 2;

      my @a = $tr->look_down('_tag' => 'a');
      for my $a (@a) {
	my $operation = sprintf "%s", lc ( ($a->content_list)[0] ) ;
	my $href = $c->uri_for($operation, $tr_data->id);
	$a->attr(href => $href);
      }


    },
    td_proc => sub {
      my ($tr_elem, $data) = @_;
      for my $column (BookDB::M::BookDB::Book->columns('list')) {
	my $column_name = $column->name;
	my $td = $tr_elem->look_down(id => $column_name);
	$td->replace_content($data->$column_name);
      }
    }
   );

  

  #warn "TRREE;;;;;", $tree->as_HTML;

  $tree;
}

1;
