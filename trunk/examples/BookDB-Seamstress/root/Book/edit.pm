package root::Book::edit;


use BookDB::M::BookDB::Book;
use base qw( HTML::Seamstress ) ;
#use base qw( BookDB::V::Seamstress ) ;

use Carp qw(carp cluck croak confess);
use Class::ISA;
use Data::Dumper;

sub new {
  my ($class, $c) = @_;


  my $html_file = sprintf "%s", $c->path_to('root/Book/edit.html');

  my $tree = __PACKAGE__->new_from_file($html_file);

  $tree;
}

sub process {
  my ($tree, $c, $stash) = @_;


  my $item = $stash->{item};

  my $form = $tree->find('form');
  my $div  = $form->find('div');
  my @div;

  for my $column ($item->columns('view')) {
    my $clone = $div->clone;

    $clone->find('label')->attr(for => "$column");
    $clone->find('label')->replace_content("$column");

    $clone->find('span')->replace_content(
      $item->to_field($column)
     );

    push @div, $clone;
  }

  $div->replace_with(@div);
  $form->attr(action => $c->uri_for('/book/do_edit', $item->id));

  $tree;

}


1;
