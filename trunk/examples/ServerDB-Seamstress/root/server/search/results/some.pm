package root::server::search::results::some;

use base qw( HTML::Seamstress ) ;

use Carp qw(carp cluck croak confess);
use Data::Dumper;

sub new {
  my ($class, $c) = @_;

  my $html_file = 
      sprintf "%s", $c->path_to('root/server/search/results/some.html');

  my $tree = __PACKAGE__->new_from_file($html_file);

  $tree;
}


sub process { 
  my ($tree, $c, $stash) = @_;

  use root::server::list;

  $tree->look_down(id => 'searchResultCount')->replace_content(
    $stash->{searchResultCount}
   );

  my $server_list = root::server::list->new($c);
  $server_list->process($c, $stash);
  $tree->push_content($server_list);

}


1;
