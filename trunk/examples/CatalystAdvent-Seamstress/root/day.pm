package root::day;

use strict;
use warnings;

use base qw( HTML::Seamstress ) ;
#use base qw( BookDB::V::Seamstress ) ;

use Carp qw(carp cluck croak confess);
use Class::ISA;
use Data::Dumper;

sub new {
  my ($class, $c) = @_;

  my $html_file = sprintf "%s", $c->path_to('root/day.html');
  my $tree = __PACKAGE__->new_from_file($html_file);

  $tree;
}

sub day_file_exists {
  my ($c, $day) = @_;
  my $file = sprintf "%s", $c->path_to('root', $c->stash->{year}, "$day.pod");
  my $bool = -e $file;
  warn "-e $file : $bool";
  $bool
}

sub day_td {
  my ($td_elem, $c, $day, $day_label) = @_;

  #$td_elem->attr(class => 'link');
  my $a = HTML::Element->new_from_lol([
    a => 
    { href  => sprintf "/%d/%d", $c->stash->{year}, $day }, 
    ucfirst $day_label
   ]);
  $td_elem->replace_content($a);

}

      

sub process {
  my ($tree, $c, $stash) = @_;

  use Date::Calc;


  $tree->look_down(id => 'pod')->replace_content($stash->{pod});

  my $day = $stash->{day} ;
	
  my %day = (
    previous => $day-1,
    next     => $day+1
   );

  for (keys %day) {
    if (day_file_exists($c, $day{$_})) {
      warn "day_td(scalar $tree->look_down(class => $_), $c, $day{$_}, $_);";
      day_td(scalar $tree->look_down(class => $_), $c, $day{$_}, $_);
    }
  }


  $tree;
}

1;



