package root::server::list;


use strict;
use warnings;

use base qw( HTML::Seamstress ) ;


use Carp qw(carp cluck croak confess);
use Data::Dumper;

use root::util;
use root::util::pager;


sub new {
  my ($class, $c) = @_;

  warn " -- atu -- @_";

  my $html_file = sprintf "%s", $c->path_to('root/server/list.html');

  my $tree = __PACKAGE__->new_from_file($html_file);

  $tree;
}



sub process {
  my ($tree, $c, $stash) = @_;

  warn " -- atu -- @_";

  my @pager = $tree->look_down(class => 'pager') ;
  for my $pager (@pager) {
    my @elem = root::util::pager->process($c, $stash);
    warn "ELEMS: @elem";
    $pager->replace_content(@elem);
  }

  $tree->table2(

    debug      => 1,
    table_data => $stash->{servers},
    tr_ld      => [ onclick => qr/./ ],
    td_proc    => sub {
      my ($tr, $data) = @_;

      my $href = sprintf "/server/view/%s", $data->name;
      for my $field (@{$stash->{fields}}) {
	warn "ffff $field";
        my $td = $tr->look_down(field => $field);
	warn $td;
	$td->replace_content($data->$field) if $td;
      }
      my $literal_href_html = root::util::literal_href($href);
      $tr->attr(onClick => $literal_href_html);

    }



   );

}



1;
