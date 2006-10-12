package root::util;

sub literal_href {

  my $href = shift;

  my $literal_href = HTML::Element->new(
    '~literal', 'text' => "window.location.href='$href'"
   );

  $literal_href;
}

1;
