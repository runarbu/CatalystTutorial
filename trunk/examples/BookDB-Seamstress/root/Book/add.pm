package root::Book::add;


use BookDB::M::BookDB::Book;
use base qw( HTML::Seamstress ) ;
#use base qw( BookDB::V::Seamstress ) ;

use Carp qw(carp cluck croak confess);
use Class::ISA;
use Data::Dumper;

sub new {
  my ($class, $c) = @_;


  my $html_file = sprintf "%s", $c->path_to('root/Book/add.html');

  my $tree = __PACKAGE__->new_from_file($html_file);

  $tree;
}

sub process {
  my ($tree, $c, $stash) = @_;


  my $form = $tree->look_down(action => '/book/do_add');
  my $div  = $form->find('div');
  my @div;

  for my $column (BookDB::M::BookDB::Book->columns('view')) {
    my $clone = $div->clone;

    $clone->find('label')->attr(for => "$column");
    $clone->find('label')->replace_content("$column");

    $clone->find('span')->replace_content(
      BookDB::M::BookDB::Book->to_field($column)
	 );

    push @div, $clone;
  }

  $div->replace_with(@div);

  $tree;

}


1;
