package root::report::list;

use base qw( HTML::Seamstress ) ;
use root::util;

use Carp qw(carp cluck croak confess);
use Data::Dumper;

sub new {
  my ($class, $c) = @_;

  my $html_file = sprintf "%s", $c->path_to('root/report/list.html');

  my $tree = __PACKAGE__->new_from_file($html_file);

  $tree;
}

sub process {
  my ($tree, $c, $stash) = @_;

  $tree->table2(
    table_data => [ keys %{$stash->{reports}} ],
    tr_ld => [ onClick => qr/.*/ ],
    tr_proc =>  sub {
      my ($self, $tr, $tr_data, $tr_base_id, $row_count) = @_;
      $tr->attr(class => 'alternate') if $row_count % 2;
    },
    td_proc => sub {
      my ($tr, $data) = @_;
      my $td = $tr->look_down('_tag' => 'td');

      my $href = sprintf "/report/%s", $data ;


      
      my $a = HTML::Element->new_from_lol([
	a => { href => $href }
       ]);
      $a->push_content($stash->{reports}->{$data});
      $td->replace_content($a);
      
      my $literal_href_html = root::util::literal_href_html($href);
      $td->look_up('_tag' => 'tr')->attr(
	onClick => $literal_href_html
       );
    }
   );
}




1;
