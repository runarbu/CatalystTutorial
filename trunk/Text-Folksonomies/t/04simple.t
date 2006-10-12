use strict;
use Text::Folksonomies;
use Test::Simple tests => 1;

my $text = q/test product 'foo bar' red 'lala yada' "hello you" green/;
ok( $#{ Text::Folksonomies->new->parse($text) } == 6 );
