package root::Borrower::list;

use BookDB::M::BookDB::Borrower;
use base qw( HTML::Seamstress ) ;
#use base qw( BookDB::V::Seamstress ) ;

use Carp qw(carp cluck croak confess);
use Class::ISA;
use Data::Dumper;

sub new {
  my ($class, $c) = @_;

  my $html_file = sprintf "%s", $c->path_to('root/Borrower/list.html');

  my $tree = __PACKAGE__->new_from_file($html_file);

  $tree;
}


sub process {
  my ($tree, $c, $stash) = @_;

  warn "TREE: " , $tree->as_HTML;

  my $primary = BookDB::M::BookDB::Borrower->primary_column;

  my $th_elem = $tree->look_down(class => 'th_column');
  my @th_elem;

  for my $column (BookDB::M::BookDB::Borrower->columns('list')) {
    my $clone = $th_elem->clone;
    $clone->replace_content($column->name);
    push @th_elem, $clone;
  }

  $th_elem->replace_with(@th_elem);

  warn "TREE2: " , $tree->as_HTML;

  #warn "CLASS_ISA2", join("\n\t", Class::ISA::self_and_super_path(ref $tree));
  #warn "pre-table2 INC: ", Dumper \%INC;
  #warn "CAN RES: " , HTML::Element->can('table2');

  my $counter;
  $tree->table2(
#  HTML::Element::table2(    $tree,

#    debug => 1,
    table_ld => [ id => 'borrowers' ],
    table_data => scalar BookDB::M::BookDB::Borrower->retrieve_all,
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
      for my $column (BookDB::M::BookDB::Borrower->columns('list')) {
	my $td = $tr_elem->look_down(class => $column->name);
	$td->replace_content($data->$column);
      }
    }
   );

  $tree;
}

1;
