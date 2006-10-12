package root::server::view::admin;

use base qw( root::server::view ) ;

use Carp qw(carp cluck croak confess);
use Data::Dumper;

sub new {
  my ($class, $c) = @_;

  my $html_file = sprintf "%s", $c->path_to('root/server/view/admin.html');

  my $tree = __PACKAGE__->new_from_file($html_file);

  $tree;
}

sub process {
  my ($tree, $c, $stash) = @_;

  $tree->SUPER::process($c, $stash);

  my ($e, $index, @E) = $tree->editableFields_Init;
  warn "THE-E, THE-TREE: ", $e, Dumper($tree);
  for my $field (@{$stash->{editableFields}}) {
    my $k = $e->clone;


#    bless $k, ref $tree;
    $k->set_label($field, $stash->{editableValues}[$index]);

    # set input field
    $k->attr(name => $field);
    my $input = $k->find('input');
    $input->attr(name => $field);
    $input->attr(value => $stash->{server}->$field);

    ++$index;
    push @E, $k;
  }

  $e->replace_with(@E);
}


1;
