package root::util::pager;

use warnings;
use strict;

use URI;

use Data::Dumper;


use base qw(HTML::Seamstress);

sub new { 


}

sub current_page {
  my $page = shift;

  HTML::Element->new_from_lol([
    span => { class => 'current-page' }, $page
   ]);
}

sub process {
  my ($self, $c, $stash) = @_;

  warn "-- atu -- @_";
  warn "pagerstash: ", Dumper($stash);

#  warn "PAGER STASH", Dumper $stash;

  my $F = $stash->{pager}->first_page;
  my $L = $stash->{pager}->last_page;
  my $C = $stash->{pager}->current_page;
  my @E;
 

  for my $page ($F .. $L) {

    warn "page: $page -> $L";
    if ($page == $C) {
      warn "push @E, current_page($page);";
      push @E, current_page($page);
    } else {
      my $elem;
      my ($lower, $higher) = ($C-2, $C+2);

      if (

	(($page >= $lower) and ($page <= $higher)) or
	    ($page == $L) or
		($page == $F)
	       ) {
	my %Q = map {
	  $c->req->param($_) 
	      ? (	$_ => $c->req->param($_) )
		  : ()
		} qw(order o2) ;

	$Q{page} = $page;

	my $uri = URI->new;
	$uri->query_form(\%Q);

	$elem = HTML::Element->new_from_lol([
	  a => {href => $uri->as_string}, $page
	 ]);
      } else {
	$elem = ".";
      }
      #      warn "push \@E, $elem;";
      push @E, $elem;
    }

  }
    @E;
}

1;
