package root::skeleton;

use BookDB::M::BookDB::Book;
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

  $tree;
}



1;
