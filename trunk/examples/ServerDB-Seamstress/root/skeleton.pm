package root::skeleton;

use base qw( HTML::Seamstress ) ;

use Carp qw(carp cluck croak confess);
use Data::Dumper;

sub new {
  my ($class, $c) = @_;

  my $html_file = sprintf "%s", $c->path_to('root/skeleton.html');

  my $tree = __PACKAGE__->new_from_file($html_file);

  $tree;
}

sub process {
  my ($tree, $c, $stash) = @_;

  # --- title rewrite
  $tree->find('title')->replace_content(
    $stash->{title} || 'Server Database'
   );

  # --- tab bar rewrites
  $tree->look_down(href => '/logout')->delete
      unless $c->req->user;

  # --- nav rewrites
  my $x = $tree->look_down(class => $stash->{nav});
  $x->attr(id => 'active');

}



1;
