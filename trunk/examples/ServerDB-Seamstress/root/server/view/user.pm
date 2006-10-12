package root::server::view::user;

use base qw( root::server::view ) ;

use Carp qw(carp cluck croak confess);
use Data::Dumper;

sub new {
  my ($class, $c) = @_;

  my $html_file = sprintf "%s", $c->path_to('root/server/view/user.html');

  my $tree = __PACKAGE__->new_from_file($html_file);

  $tree;
}

sub process {
  my ($tree, $c, $stash) = @_;

  $tree->SUPER::process($c, $stash);

  my ($e, $index, @E) = $tree->editableFields_Init;
  for my $field (@{$stash->{editableFields}}) {
    warn "FIELD... $field";
    my $k = $e->clone;

    $k->set_label($field, $stash->{editableValues}[$index]);

    $k->push_content($stash->{server}->$field);

    ++$index;
    push @E, $k;
  }

  $e->replace_with(@E);
}


1;
