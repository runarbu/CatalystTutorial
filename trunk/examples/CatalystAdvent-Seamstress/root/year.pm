package root::year;

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

  my $html_file = sprintf "%s", $c->path_to('root/year.html');

  my $tree = __PACKAGE__->new_from_file($html_file);

  $tree;
}

sub today_file_exists {
  my ($c, $day) = @_;
  my $file = sprintf "%s", $c->path_to('root', $c->stash->{year}, "$day.pod");
  my $bool = -e $file;
  warn "-e $file : $bool";
  $bool
}

sub today_td {
  my ($td_elem, $c, $day,) = @_;

  $td_elem->attr(class => 'link');
  my $a = HTML::Element->new_from_lol([
    a => 
    { href  => sprintf "/%d/%d", $c->stash->{year}, $day }, 
    $day
   ]);
  $td_elem->replace_content($a);

}

      

sub process {
  my ($tree, $c, $stash) = @_;

  use Date::Calc;


  $tree->look_down(id => 'year')->replace_content($stash->{year});


  $tree->table2(
    debug => 1,
    table_data => $stash->{calendar},
    tr_ld => [ class => 'data_row' ],
    td_proc => sub {
      my ($tr_elem, $data) = @_;
      my @td = $tr_elem->find('td');
      for (0..@td-1) {

	my $day = $data->[$_] ;
	
	if (today_file_exists($c, $day)) {
	  warn " today_td($td[$_], $stash, $day);";
	  today_td($td[$_], $c, $day);
	} else {
	  $td[$_]->replace_content($data->[$_]) ;
	}
      }
    }
   );

  $tree->look_down(id => 'notes')->replace_content(
    Catalyst::View::Seamstress->page2tree(
      $c, "root::notes::$stash->{year}"
     )
       );


  $tree;
}

1;



