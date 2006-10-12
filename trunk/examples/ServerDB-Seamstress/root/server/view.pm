package root::server::view;

use base qw( HTML::Seamstress ) ;

use Carp qw(carp cluck croak confess);
use Data::Dumper;

sub new {
  my ($class, $c) = @_;

  my $html_file = sprintf "%s", $c->path_to('root/server/view.html');

  my $tree = __PACKAGE__->new_from_file($html_file);

  $tree;
}




sub editableFields_Init {
  my ($tree, $c, $stash) = @_;

  my $e = $tree->look_down(class => 'editableFields');
  warn "process::e - ", $e->as_HTML;
  my $index = 0;

  ($e, 0);

}

sub set_label {
  my ($k, $field, $value) = @_;

  warn "HERE IS K: ", $k->as_HTML;

  # set label
  my $label = $k->find('label');

  $label->attr(for => $field) ;
  $label->find('span')->replace_content($value);

}



sub process {
  my ($tree, $c, $stash) = @_;

  my $is_admin = $stash->{admin};

  # common: set form tag
  $tree->look_down('_tag' => 'form')->attr(
    action => sprintf "/server/do_edit/%s", $stash->{server}{name}
   );

  # common: set server name
  $tree->look_down('_tag' => 'legend')->splice_content(
    1,1,
    sprintf "> %s", $stash->{server}{name}
   );



  # common: set read only fields
  my @F;
  $index = 0;
  my $div = $tree->look_down(class => 'roFields');
  use Data::Dumper;
  warn Dumper(" - stash - ", $stash);
  for my $field (@{$stash->{roFields}}) {
    warn "FFFFIELD: $field";
    my $k = $div->clone;
    $k->find('label')->attr(for => $field);
    $k->find('span')->replace_content($stash->{roValues}[$index++]);
    $k->push_content($stash->{server}->$field);
    push @F, $k;
  }

  $div->replace_content(@F);

}



1;
