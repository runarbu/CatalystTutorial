package root::notes::2005;

use strict;
use warnings;

use base qw( HTML::Seamstress ) ;
#use base qw( BookDB::V::Seamstress ) ;

use Carp qw(carp cluck croak confess);
use Class::ISA;
use Data::Dumper;

sub new {
  my ($class, $c) = @_;

  #warn '__NEW__ called';

  my $html_file = sprintf "%s", $c->path_to('root/notes/2005.html');

  my $tree = __PACKAGE__->new_from_file($html_file);

  $tree;
}

sub process {
  my ($tree, $c, $stash) = @_;



  $tree;
}

1;



